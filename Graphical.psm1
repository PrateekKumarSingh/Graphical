Get-ChildItem "$PSScriptRoot\Source\" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Exporting the members and their aliases
Export-ModuleMember Show-Graph -Alias Graph
