# Dot Sourcing files

Get-ChildItem "$PSScriptRoot\Source\" | ForEach-Object {
   . $_.FullName
}

# Exporting the members and their aliases
Export-ModuleMember -Function "*-*" -Alias *
