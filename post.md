## GitHub Tracker

Saw a tweet, GitHub repo stats are kept for  < 14 days, and the author created an Azure function to store the stats.

So, let's do it in PowerShell and then create an Azure function.

## Outcome

- Use my popular PowerShell Excel module, store the stats in an Excel file
- Set up the stats collection on an Azure Function timer
- Set up an Azure HTTP endpoint to download the Excel file
- Design it so the PowerShell
    - Can be run natively at the command line, simplifies debugging
    - Can be run as a local Azure function, enables testing the endpoints and timer locally
    - Can be run as an Azure function, in Azure. "Production"

## PSGitHubTracker

In essence:

- Pull three variables from `$env`, `Owner`, `Repo` and `GithubPAT`
    - Using `$env` let's you set these variable in the Azure Function configuration. This way you don't leak your GithubPAT (Public Access Token) when versioning your code in GitHub.

```
function Get-GitHubStats {
    [CmdletBinding()]
    param()

    $owner = $env:Owner
    $repo = $env:env:Owner
    $Headers = @{"Authorization" = "token $($env:GithubPAT)" }

    $baseUrl = "https://api.github.com/repos/$owner/$repo/traffic"
    $endPoints = "popular/referrers", "popular/paths", "views", "clones"

    $xlParms = @{
        Path     = Get-ExcelFilename
        AutoSize = $true
        Append   = $true
    }

    function EnrichData {
        param($target)

        $target | Add-member -PassThru -MemberType NoteProperty -Name DateCollected -Value (Get-Date)
    }

    foreach ($endPoint in $endPoints) {

        $xlParms.WorksheetName = $endPoint.split('/')[-1]
        $url = "$baseUrl/$endPoint"
        $data = Invoke-RestMethod $url -Headers $Headers

        switch -RegEx ($xlParms.WorksheetName) {
            "views|clones" {
                $xlParms.InputObject = EnrichData $data.($xlParms.WorksheetName)
                Export-Excel @xlParms
            }
            default {
                $xlParms.InputObject = EnrichData $data
                Export-Excel @xlParms
            }
        }
    }

    Write-Verbose "Updated: $($xlParms.Path)"
}
```

## Setup Azure, VS Code, and GitHub

You need to setup your environment.

- [Quickstart: Create an Azure Functions project using Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code?pivots=programming-language-powershell)
- https://agazoth.github.io/blogpost/2019/04/29/Powershell-Functions-In-Azure-The-Easy-Way.html
- [Azure Functions PowerShell developer guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-powershell)

- [Create a GitHub Public Access Token (PAT)](https://github.com/settings/tokens)
    - For this example, I stored it in `$env:GithubPAT`. Is simplifies testing the code locally and then deploying to the Cloud
- Create two functions, a timer trigger and an http trigger
- Add the module to the Azure function
- Add a Modules directory, subdir and the psm1