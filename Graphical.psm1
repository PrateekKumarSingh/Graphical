Get-ChildItem -Path "$PSScriptRoot\src\" -Filter *.ps1 | ForEach-Object -Process {
    . $_.FullName
}

# Exporting the members and their aliases
Export-ModuleMember -Function Show-Graph -Alias Graph
