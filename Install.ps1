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
        Write-Verbose "`'$ModuleName`' module installation started"

        $Files = @(
            'Graphical.psd1',
            'Graphical.psm1',
            $(Join-Path 'src' 'Show-Graph.ps1'),
            $(Join-Path 'src' 'Get-BarPlot.ps1'),
            $(Join-Path 'src' 'Get-LinePlot.ps1'),
            $(Join-Path 'src' 'Get-ScatterPlot.ps1'),
            $(Join-Path 'src' 'UtilityFunctions.ps1')
        )

        if (-not $InstallDirectory) {
            $PersonalModules = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath WindowsPowerShell\Modules
            Write-Verbose "No installation directory was provided"
            
            if (($env:PSModulePath -split ';') -notcontains $PersonalModules) {
                Write-Warning "$ModuleName personal module path '$PersonalModules' not found in '`$env:PSModulePath'"
            }
            
            if (-not (Test-Path $PersonalModules)) {
                Write-Error "$ModuleName path '$PersonalModules' does not exist"
            }
            
            $InstallDirectory = Join-Path -Path $PersonalModules -ChildPath $ModuleName
            Write-Verbose "Begin installation at: `'$PersonalModules`'"
        }

        if (-not (Test-Path $InstallDirectory)) {
            New-Item -Path $InstallDirectory -ItemType Directory -EA Stop -Verbose | Out-Null
            New-Item -Path $(Join-Path $InstallDirectory src) -ItemType Directory -EA Stop -Verbose | Out-Null
            Write-Verbose "$ModuleName created module folder '$InstallDirectory'"
        }

        $WebClient = New-Object System.Net.WebClient

        $Files | ForEach-Object {
            $File = $installDirectory,'\',$_.replace('/','\') -join ''
            $URL = $GitPath,'/',$_.replace('\','/') -join ''
            $WebClient.DownloadFile($URL, $File)

            Write-Verbose "Downloading file '$(Split-Path $_ -Leaf)'"
        }

        Write-Verbose "Module installed successfully!"
    }
    Catch {
        throw "Failed installing the module in the install directory '$InstallDirectory': $_"
    }
$VerbosePreference = $Pre
