Set-StrictMode -v latest
$ErrorActionPreference = "Stop"

function Main([string[]] $mainargs)
{
    [bool] $dryrun = $false
    if ($mainargs -contains "-dryrun")
    {
        [bool] $dryrun = $true
    }


    if ($env:windir)
    {
        [string] $nugeturl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

        Log ("Downloading: '" + $nugeturl + "' -> 'nuget.exe'")
        Invoke-WebRequest $nugeturl -UseBasicParsing -OutFile nuget.exe

        Log ("Clearing nuget caches...")
        if (!$dryrun)
        {
            ./nuget.exe locals all -clear
        }
    }


    [string[]] $nugetpaths = "C:\Users\*\.nuget","C:\Users\*\AppData\*\NuGet","/home/*/.nuget"
    [string[]] $nugetfolders = @($nugetpaths | ? { Test-Path $_ } | % { dir $_ | % { $_.FullName }})

    Log ("Found " + $nugetfolders.Count + " folders:")
    if ($nugetfolders.Count -gt 0)
    {
        Log ("`n  '" + ($nugetfolders -join "'`n  '") + "'")
    }

    foreach ($nugetfolder in $nugetfolders)
    {
        Log ("Deleting: '" + $nugetfolder + "'")
        if (!$dryrun)
        {
            for ([int] $i=0; $i -lt 5 -and (Test-Path $nugetfolder); $i++)
            {
                try
                {
                    rd -Recurse -Force $nugetfolder
                }
                catch
                {
                    Log ("Error: " + $_.Exception)
                }
                if (Test-Path $nugetfolder)
                {
                    Log ("Waiting for folder to be deleted...")
                    Start-Sleep 5
                }
            }
        }
    }
}

function Log([string] $message, $color)
{
    [string] $now = [DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss")
    if ($color)
    {
        Write-Host ($now + ": " + $message) -f $color
    }
    else
    {
        Write-Host ($now + ": " + $message) -f Green
    }
}

Main $args
