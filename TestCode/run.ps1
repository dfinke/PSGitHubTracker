param($Request, $TriggerMetadata)

# $owner = $env:Owner
# $repo = $env:Repo
# $Headers = @{"Authorization" = "token $($env:GithubPAT)" }

# $baseUrl = "https://api.github.com/repos/$owner/$repo/traffic"
# $endPoints = "popular/referrers", "popular/paths", "views", "clones"

# if (!(Test-Path 'D:\home\site')) {
#     $path = "$env:TEMP"
# }
# else {
#     $path = 'D:\home\site\ExcelOutput'
#     if (!(Test-Path $path)) {
#         $null = mkdir $path
#     }
# }

# $xlParms = @{
#     Path     = "$path\GitHubTracker.xlsx"
#     AutoSize = $true
#     Append   = $true
# }

# function EnrichData {
#     param($target)

#     $target | Add-member -PassThru -MemberType NoteProperty -Name DateCollected -Value (Get-Date)
# }

# foreach ($endPoint in $endPoints) {

#     $xlParms.WorksheetName = $endPoint.split('/')[-1]
#     $url = "$baseUrl/$endPoint"
#     $data = Invoke-RestMethod $url -Headers $Headers

#     switch -RegEx ($xlParms.WorksheetName) {
#         "views|clones" {
#             $xlParms.InputObject = EnrichData $data.($xlParms.WorksheetName)
#             Export-Excel @xlParms
#         }
#         default {
#             $xlParms.InputObject = EnrichData $data
#             Export-Excel @xlParms
#         }
#     }
# }

Get-GitHubStats

Push-OutputBinding -Name Response -Value @{
    StatusCode = "OK"
    Body       = "Done"
}
