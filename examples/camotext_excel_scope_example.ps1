<#
NOTE: FOR DEMONSTRATION PURPOSES ONLY; DO NOT USE IN PRODUCTION
WITHOUT THOROUGH TESTING FOR YOUR IMPLEMENTATION

camotext_excel_scope_example.ps1

Example native PowerShell integration for CamoTextCLI:
- Accepts an input .xlsx file path
- Anonymizes one selected column OR one selected row (not the entire workbook)
- Saves output to a user-provided folder, or creates a new folder on Desktop by default

Requirements:
- Windows PowerShell 5.1+ or PowerShell 7+
- Microsoft Excel installed locally (COM automation)
- CamoTextCLI executable available on PATH as "camo" (or pass -CamoPath)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputXlsx,

    [string]$OutputFolder,

    [string]$SheetName,

    [string]$Column,

    [int]$Row,

    [string]$CamoPath = "camo"
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

function ConvertTo-KeyMap {
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

if (-not (Test-Path -LiteralPath $InputXlsx -PathType Leaf)) {
    throw "Input XLSX file was not found: $InputXlsx"
}

$inputExtension = [System.IO.Path]::GetExtension($InputXlsx)
if ($inputExtension -ne ".xlsx") {
    throw "Input file must be .xlsx. Received: $inputExtension"
}

if ([string]::IsNullOrWhiteSpace($Column) -and ($PSBoundParameters.ContainsKey("Row") -eq $false)) {
    throw "Specify either -Column or -Row."
}

if (-not [string]::IsNullOrWhiteSpace($Column) -and $PSBoundParameters.ContainsKey("Row")) {
    throw "Specify only one scope selector: -Column OR -Row."
}

if ($PSBoundParameters.ContainsKey("Row") -and $Row -lt 1) {
    throw "Row index must be >= 1."
}

if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
    $OutputFolder = Resolve-DefaultOutputFolder
}

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$resolvedInputPath = (Resolve-Path -LiteralPath $InputXlsx).Path
$outputFileName = "anonymized_{0}" -f [System.IO.Path]::GetFileName($resolvedInputPath)
$outputXlsx = Join-Path -Path $OutputFolder -ChildPath $outputFileName
Copy-Item -LiteralPath $resolvedInputPath -Destination $outputXlsx -Force

$excel = $null
$workbook = $null
$worksheet = $null
$processedCells = 0
$skippedNonTextCells = 0
$keyFilePath = $null

try {
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

    if (-not [string]::IsNullOrWhiteSpace($Column)) {
        $columnIndex = ConvertTo-ColumnIndex -ColumnToken $Column
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
        $targetRow = $Row
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
        # Optimal separator for reliable splitting: unlikely to appear in regular worksheet text.
        $separator = " <<CAMOTEXT_CELL_SPLIT_{0}>> " -f ([guid]::NewGuid().ToString("N"))
        $joinedSourceText = [string]::Join($separator, ($targetCells | ForEach-Object { $_.OriginalValue }))

        $inputDir = [System.IO.Path]::GetDirectoryName($resolvedInputPath)
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInputPath)
        $scopeLabel = if (-not [string]::IsNullOrWhiteSpace($Column)) { "column_{0}" -f $Column } else { "row_{0}" -f $Row }
        $keyFilePath = Join-Path -Path $inputDir -ChildPath ("{0}_{1}_key.json" -f $baseName, $scopeLabel)

        $joinedAnonymizedText = Invoke-CamoBatchText -Text $joinedSourceText -ExePath $CamoPath -KeyPath $keyFilePath
        $splitAnonymizedValues = [Regex]::Split($joinedAnonymizedText, [Regex]::Escape($separator))

        if ($splitAnonymizedValues.Count -eq $targetCells.Count) {
            for ($i = 0; $i -lt $targetCells.Count; $i++) {
                $targetCells[$i].AnonymizedValue = $splitAnonymizedValues[$i]
            }
        }
        else {
            # Fallback: use key mapping to transform each cell if separator-based split does not round-trip.
            $keyMap = ConvertTo-KeyMap -KeyPath $keyFilePath
            for ($i = 0; $i -lt $targetCells.Count; $i++) {
                $targetCells[$i].AnonymizedValue = Apply-KeyMapToText -Text $targetCells[$i].OriginalValue -KeyMap $keyMap
            }
        }

        foreach ($entry in $targetCells) {
            $worksheet.Cells.Item($entry.Row, $entry.Column).Value2 = $entry.AnonymizedValue
        }
    }

    $processedCells = $targetCells.Count
    $workbook.Save()
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

Write-Host "Completed. Processed text cells: $processedCells"
if ($skippedNonTextCells -gt 0) {
    Write-Host "Skipped non-text cells: $skippedNonTextCells"
}
Write-Host "Output file: $outputXlsx"
if ($keyFilePath) {
    Write-Host "Anonymization key file: $keyFilePath"
}
