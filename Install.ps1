<#
    .SYNOPSIS
        Download the module files from GitHub.

    .DESCRIPTION
        Download the module files from GitHub to the local client in the module folder.
#>

[CmdLetBinding()]
Param (
    [ValidateNotNullOrEmpty()]
    [String]$ModuleName = 'Graphical',
    [String]$InstallDirectory,
    [ValidateNotNullOrEmpty()]
    [String]$GitPath = 'https://raw.githubusercontent.com/PrateekKumarSingh/Graphical/master'
)

$Pre = $VerbosePreference
$VerbosePreference = 'continue'

    Try {
        Write-Verbose "$ModuleName module installation started"

        $Files = @(
            'Graphical.psd1',
            'Graphical.psm1',
            'README.md',
            'Source/Show-Graph.ps1',
            'Source/Get-BarPlot.ps1',
            'Source/Get-ScatterPlot.ps1',
            'Source/UtilityFunctions.ps1'
        )
    }
    Catch {
        throw "Failed installing the module in the install directory '$InstallDirectory': $_"
    }

    Try {
        if (-not $InstallDirectory) {
            Write-Verbose "$ModuleName no installation directory provided"

            $PersonalModules = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath WindowsPowerShell\Modules

            if (($env:PSModulePath -split ';') -notcontains $PersonalModules) {
                Write-Warning "$ModuleName personal module path '$PersonalModules' not found in '`$env:PSModulePath'"
            }

            if (-not (Test-Path $PersonalModules)) {
                Write-Error "$ModuleName path '$PersonalModules' does not exist"
            }

            $InstallDirectory = Join-Path -Path $PersonalModules -ChildPath $ModuleName
            Write-Verbose "$ModuleName default installation directory is '$InstallDirectory'"
        }

        if (-not (Test-Path $InstallDirectory)) {
            New-Item -Path $InstallDirectory -ItemType Directory -EA Stop -Verbose | Out-Null
            New-Item -Path $InstallDirectory\Source -ItemType Directory -EA Stop -Verbose | Out-Null
            Write-Verbose "$ModuleName created module folder '$InstallDirectory'"
        }

        $WebClient = New-Object System.Net.WebClient

        $Files | ForEach-Object {
            $File = $installDirectory,'\',$($_ -replace '/','\') -join ''
            $URL = $GitPath,'/',$_ -join ''
            "$URL $File"

            $WebClient.DownloadFile($URL,$File)
            Write-Verbose "$ModuleName installed module file '$_'"
        }

        Write-Verbose "$ModuleName module installation successful"
    }
    Catch {
        throw "Failed installing the module in the install directory '$InstallDirectory': $_"
    }
$VerbosePreference = $Pre
