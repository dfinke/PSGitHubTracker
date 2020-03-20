param($Request, $TriggerMetadata)

$fileName = Get-ExcelFilename
$xlFileName = Split-Path -Leaf $fileName

$bytes = Get-Content -AsByteStream $fileName -Raw

Push-OutputBinding -Name Response -Value @{
    StatusCode  = 'OK'
    Body        = $bytes
    ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    Headers     = @{ 'Content-Disposition' = "attachment; filename=$($xlFileName)" }
}