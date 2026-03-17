<#
NOTE: FOR DEMONSTRATION PURPOSES ONLY; DO NOT USE IN PRODUCTION
WITHOUT THOROUGH TESTING FOR YOUR IMPLEMENTATION

camotext_excel_scope_example.ps1

Example native PowerShell integration for CamoTextCLI:
- Accepts an input .xlsx file path OR folder containing .xlsx files
- Anonymizes one selected column OR one selected row (not the entire workbook)
- Saves output to a user-provided folder, or creates a new folder on Desktop by default
- Saves the anonymization key to the input workbook directory

Requirements:
- Windows PowerShell 5.1+ or PowerShell 7+
- Microsoft Excel installed locally (COM automation)
- CamoTextCLI executable available on PATH as "camo" (or pass -CamoPath)
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$InputPath,

    [string]$InputXlsx,

    [string]$OutputFolder,

    [string]$SheetName,

    [string]$Column,

    [Nullable[int]]$Row,

    [string]$JoinDelimiter = ", ",

    [string]$CamoPath = "camo",

    [switch]$NoPauseOnError
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-DefaultOutputFolder {
    $desktopPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
    if ([string]::IsNullOrWhiteSpace($desktopPath)) {
        $desktopPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
    }

    $folderName = "CamoTextCLI_Excel_Anonymized_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss")
    return (Join-Path -Path $desktopPath -ChildPath $folderName)
}

function Pause-OnError {
    if ($NoPauseOnError) {
        return
    }
    if (-not [Environment]::UserInteractive) {
        return
    }

    try {
        [void](Read-Host "Press Enter to exit")
    }
    catch {
        # Ignore prompt errors in non-standard hosts.
    }
}

function Resolve-WorkbookFromInputPath {
    param([Parameter(Mandatory = $true)][string]$ProvidedPath)

    $raw = $ProvidedPath.Trim()
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw "Input path is empty."
    }

    $candidates = New-Object System.Collections.Generic.List[string]

    function Add-Candidate([string]$value) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            return
        }
        if (-not $candidates.Contains($value)) {
            $candidates.Add($value) | Out-Null
        }
    }

    Add-Candidate $raw

    $trimmedDouble = $raw.Trim('"')
    Add-Candidate $trimmedDouble

    $trimmedBoth = $trimmedDouble.Trim("'")
    Add-Candidate $trimmedBoth

    $expanded = [Environment]::ExpandEnvironmentVariables($trimmedBoth)
    Add-Candidate $expanded

    if ($expanded.StartsWith("~")) {
        $home = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
        $expandedHome = Join-Path -Path $home -ChildPath $expanded.Substring(1).TrimStart('\','/')
        Add-Candidate $expandedHome
    }

    if (-not [System.IO.Path]::IsPathRooted($expanded)) {
        Add-Candidate (Join-Path -Path (Get-Location).Path -ChildPath $expanded)
    }

    $resolvedTarget = $null
    foreach ($candidate in $candidates) {
        $candidateNoTrailingSlash = $candidate
        if ($candidateNoTrailingSlash.Length -gt 3) {
            $candidateNoTrailingSlash = $candidateNoTrailingSlash.TrimEnd('\','/')
        }

        if (Test-Path -LiteralPath $candidateNoTrailingSlash) {
            $resolvedTarget = (Resolve-Path -LiteralPath $candidateNoTrailingSlash).Path
            break
        }

        try {
            $resolvedWildcard = Resolve-Path -Path $candidateNoTrailingSlash -ErrorAction Stop
            if ($resolvedWildcard.Count -eq 1) {
                $resolvedTarget = $resolvedWildcard[0].Path
                break
            }
        }
        catch {
            # Keep trying other candidates.
        }
    }

    if (-not $resolvedTarget) {
        throw "Input path was not found. Tried: $($candidates -join '; ')"
    }

    if (Test-Path -LiteralPath $resolvedTarget -PathType Leaf) {
        $resolvedFile = $resolvedTarget
        $ext = [System.IO.Path]::GetExtension($resolvedFile)
        if ($ext.ToLowerInvariant() -ne ".xlsx") {
            throw "Input file must be .xlsx. Received: $ext"
        }
        return $resolvedFile
    }

    $xlsxFiles = Get-ChildItem -LiteralPath $resolvedTarget -File -Filter "*.xlsx" | Sort-Object Name
    if ($xlsxFiles.Count -eq 0) {
        throw "No .xlsx files found in directory: $resolvedTarget"
    }
    if ($xlsxFiles.Count -eq 1) {
        return $xlsxFiles[0].FullName
    }
    if (-not [Environment]::UserInteractive) {
        throw "Multiple .xlsx files found in '$resolvedTarget'. Provide a specific file path when running non-interactively."
    }

    Write-Host "Multiple .xlsx files found in '$resolvedTarget'. Choose one:"
    for ($i = 0; $i -lt $xlsxFiles.Count; $i++) {
        Write-Host ("  [{0}] {1}" -f ($i + 1), $xlsxFiles[$i].Name)
    }

    $selection = Read-Host "Enter file number"
    if ($selection -notmatch "^\d+$") {
        throw "Invalid selection. Expected a number."
    }
    $index = [int]$selection
    if ($index -lt 1 -or $index -gt $xlsxFiles.Count) {
        throw "Selection out of range."
    }
    return $xlsxFiles[$index - 1].FullName
}

function Resolve-ScopeSelection {
    param(
        [string]$ColumnToken,
        [Nullable[int]]$RowNumber
    )

    if (-not [string]::IsNullOrWhiteSpace($ColumnToken) -and $RowNumber.HasValue) {
        throw "Specify only one scope selector: -Column OR -Row."
    }

    if ([string]::IsNullOrWhiteSpace($ColumnToken) -and (-not $RowNumber.HasValue)) {
        if (-not [Environment]::UserInteractive) {
            throw "Specify either -Column or -Row when running non-interactively."
        }

        $choice = (Read-Host "Anonymize a Column or Row? Enter C or R").Trim().ToUpperInvariant()
        if ($choice -eq "C") {
            $ColumnToken = Read-Host "Enter column (e.g., A, C, AA, or 3)"
        }
        elseif ($choice -eq "R") {
            $rowInput = Read-Host "Enter 1-based row number"
            if ($rowInput -notmatch "^\d+$") {
                throw "Invalid row number."
            }
            $RowNumber = [int]$rowInput
        }
        else {
            throw "Invalid selection. Enter C or R."
        }
    }

    if ($RowNumber.HasValue -and $RowNumber.Value -lt 1) {
        throw "Row index must be >= 1."
    }

    if (-not [string]::IsNullOrWhiteSpace($ColumnToken)) {
        return @{
            Mode = "Column"
            ColumnToken = $ColumnToken.Trim()
            RowNumber = $null
        }
    }

    return @{
        Mode = "Row"
        ColumnToken = $null
        RowNumber = $RowNumber.Value
    }
}

function Resolve-CamoExecutable {
    param([Parameter(Mandatory = $true)][string]$ExeOrCommand)

    $cmd = Get-Command -Name $ExeOrCommand -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    if (Test-Path -LiteralPath $ExeOrCommand -PathType Leaf) {
        return (Resolve-Path -LiteralPath $ExeOrCommand).Path
    }

    throw "Unable to locate CamoTextCLI ('$ExeOrCommand'). Add 'camo' to PATH or pass -CamoPath with a full executable path."
}

function ConvertTo-ColumnIndex {
    param([Parameter(Mandatory = $true)][string]$ColumnToken)

    if ($ColumnToken -match "^\d+$") {
        $parsed = [int]$ColumnToken
        if ($parsed -lt 1) {
            throw "Column index must be >= 1."
        }
        return $parsed
    }

    if ($ColumnToken -notmatch "^[A-Za-z]+$") {
        throw "Column must be Excel letters (e.g., A, AA) or 1-based numeric index."
    }

    $sum = 0
    foreach ($ch in $ColumnToken.ToUpperInvariant().ToCharArray()) {
        $sum = ($sum * 26) + ([int][char]$ch - [int][char]'A' + 1)
    }
    return $sum
}

function Invoke-CamoBatchText {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$ExePath,
        [Parameter(Mandatory = $true)][string]$KeyPath
    )

    $tmpInput = [System.IO.Path]::GetTempFileName()
    $tmpOutput = [System.IO.Path]::GetTempFileName()

    try {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($tmpInput, $Text, $utf8NoBom)
        $args = @("--input", $tmpInput, "--output", $tmpOutput, "--dump-key", $KeyPath)

        $cliOutput = & $ExePath @args 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            throw "CamoTextCLI failed with exit code $exitCode. Output: $($cliOutput | Out-String)"
        }

        return (Get-Content -Path $tmpOutput -Raw -Encoding UTF8)
    }
    finally {
        Remove-Item -Path $tmpInput -ErrorAction SilentlyContinue
        Remove-Item -Path $tmpOutput -ErrorAction SilentlyContinue
    }
}

function Read-KeyMap {
    param([Parameter(Mandatory = $true)][string]$KeyPath)

    if (-not (Test-Path -LiteralPath $KeyPath -PathType Leaf)) {
        throw "Expected key file was not created: $KeyPath"
    }

    $jsonObject = Get-Content -LiteralPath $KeyPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $map = @{}
    foreach ($prop in $jsonObject.PSObject.Properties) {
        $map[$prop.Name] = [string]$prop.Value
    }
    return $map
}

function Apply-KeyMapToText {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][hashtable]$KeyMap
    )

    $result = $Text
    foreach ($original in ($KeyMap.Keys | Sort-Object { $_.Length } -Descending)) {
        $replacement = [string]$KeyMap[$original]
        $result = $result.Replace($original, $replacement)
    }
    return $result
}

$excel = $null
$workbook = $null
$worksheet = $null
$processedCells = 0
$skippedNonTextCells = 0
$keyFilePath = $null
$resolvedInputPath = $null
$outputXlsx = $null

try {
    if (-not [string]::IsNullOrWhiteSpace($InputPath) -and -not [string]::IsNullOrWhiteSpace($InputXlsx) -and ($InputPath -ne $InputXlsx)) {
        throw "Provide only one input parameter, or ensure -InputPath and -InputXlsx match."
    }

    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        $InputPath = $InputXlsx
    }

    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        if (-not [Environment]::UserInteractive) {
            throw "Provide -InputPath (or -InputXlsx) when running non-interactively."
        }
        $InputPath = Read-Host "Enter input .xlsx path or folder containing .xlsx files"
    }

    if ([string]::IsNullOrWhiteSpace($JoinDelimiter)) {
        throw "JoinDelimiter cannot be empty."
    }

    $resolvedInputPath = Resolve-WorkbookFromInputPath -ProvidedPath $InputPath
    $scope = Resolve-ScopeSelection -ColumnToken $Column -RowNumber $Row
    $resolvedCamoPath = Resolve-CamoExecutable -ExeOrCommand $CamoPath

    $inputDir = [System.IO.Path]::GetDirectoryName($resolvedInputPath)
    if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
        $OutputFolder = Resolve-DefaultOutputFolder
    }
    if (-not (Test-Path -LiteralPath $OutputFolder)) {
        New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
    }

    $resolvedOutputFolder = (Resolve-Path -LiteralPath $OutputFolder).Path
    if ($resolvedOutputFolder -eq $inputDir) {
        throw "OutputFolder cannot equal the input file directory, because key files are saved to the input directory."
    }

    $outputFileName = "anonymized_{0}" -f [System.IO.Path]::GetFileName($resolvedInputPath)
    $outputXlsx = Join-Path -Path $resolvedOutputFolder -ChildPath $outputFileName
    Copy-Item -LiteralPath $resolvedInputPath -Destination $outputXlsx -Force

    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    $workbook = $excel.Workbooks.Open($outputXlsx)
    if ([string]::IsNullOrWhiteSpace($SheetName)) {
        $worksheet = $workbook.Worksheets.Item(1)
    }
    else {
        $worksheet = $workbook.Worksheets.Item($SheetName)
    }

    if (-not $worksheet) {
        throw "Unable to select worksheet."
    }

    $targetCells = New-Object System.Collections.Generic.List[object]

    if ($scope.Mode -eq "Column") {
        $columnIndex = ConvertTo-ColumnIndex -ColumnToken $scope.ColumnToken
        $startRow = [int]$worksheet.UsedRange.Row
        $endRow = $startRow + [int]$worksheet.UsedRange.Rows.Count - 1

        for ($r = $startRow; $r -le $endRow; $r++) {
            $cell = $worksheet.Cells.Item($r, $columnIndex)
            $value = $cell.Value2

            if ($null -eq $value -or $cell.HasFormula -or $value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) {
                if ($null -ne $value -and $value -isnot [string]) {
                    $skippedNonTextCells++
                }
                continue
            }

            $targetCells.Add([PSCustomObject]@{
                Row = $r
                Column = $columnIndex
                OriginalValue = [string]$value
                AnonymizedValue = $null
            }) | Out-Null
        }
    }
    else {
        $targetRow = $scope.RowNumber
        $startColumn = [int]$worksheet.UsedRange.Column
        $endColumn = $startColumn + [int]$worksheet.UsedRange.Columns.Count - 1

        for ($c = $startColumn; $c -le $endColumn; $c++) {
            $cell = $worksheet.Cells.Item($targetRow, $c)
            $value = $cell.Value2

            if ($null -eq $value -or $cell.HasFormula -or $value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) {
                if ($null -ne $value -and $value -isnot [string]) {
                    $skippedNonTextCells++
                }
                continue
            }

            $targetCells.Add([PSCustomObject]@{
                Row = $targetRow
                Column = $c
                OriginalValue = [string]$value
                AnonymizedValue = $null
            }) | Out-Null
        }
    }

    if ($targetCells.Count -gt 0) {
        $joinedSourceText = [string]::Join($JoinDelimiter, ($targetCells | ForEach-Object { $_.OriginalValue }))

        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInputPath)
        $scopeLabel = if ($scope.Mode -eq "Column") { "column_{0}" -f $scope.ColumnToken } else { "row_{0}" -f $scope.RowNumber }
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $keyFilePath = Join-Path -Path $inputDir -ChildPath ("{0}_{1}_{2}_key.json" -f $baseName, $scopeLabel, $timestamp)

        [void](Invoke-CamoBatchText -Text $joinedSourceText -ExePath $resolvedCamoPath -KeyPath $keyFilePath)
        $keyMap = Read-KeyMap -KeyPath $keyFilePath

        for ($i = 0; $i -lt $targetCells.Count; $i++) {
            $targetCells[$i].AnonymizedValue = Apply-KeyMapToText -Text $targetCells[$i].OriginalValue -KeyMap $keyMap
        }

        foreach ($entry in $targetCells) {
            $worksheet.Cells.Item($entry.Row, $entry.Column).Value2 = $entry.AnonymizedValue
        }
    }

    $processedCells = $targetCells.Count
    $workbook.Save()

    Write-Host "Completed. Processed text cells: $processedCells"
    if ($skippedNonTextCells -gt 0) {
        Write-Host "Skipped non-text cells: $skippedNonTextCells"
    }
    Write-Host "Output file: $outputXlsx"
    if ($keyFilePath) {
        Write-Host "Anonymization key file: $keyFilePath"
    }
}
catch {
    Write-Host ("ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "Tip: Example usage -> .\camotext_excel_scope_example.ps1 -InputPath 'C:\data\file.xlsx' -Column C" -ForegroundColor Yellow
    Write-Host "Tip: You can also use -InputXlsx, environment vars, ~, relative paths, or a folder path containing .xlsx files." -ForegroundColor Yellow
    Pause-OnError
    exit 1
}
finally {
    if ($workbook) {
        $workbook.Close($true)
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)
    }
    if ($worksheet) {
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($worksheet)
    }
    if ($excel) {
        $excel.Quit()
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
    }

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
