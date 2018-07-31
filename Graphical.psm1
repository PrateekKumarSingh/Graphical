$BasePath = $PSScriptRoot

# define class sequence
$classList = @(
    'Graph'
)

Get-ChildItem "$BasePath\Source\" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# importing enumerators and hashtables sequentially
foreach ($item in $classList) {
    Write-Verbose "Dot sourcing '$item.ps1'" 
    . "$BasePath\Source\classes\$item.ps1"
}
# Exporting the members and their aliases
Export-ModuleMember *-* -Alias Graph

#$Datapoints = (21..278|Get-Random -Count 50)
#Show-Graph -Datapoints $Datapoints -GraphTitle "Avg. CPU utilization" -YAxisTitle "Percent" -Type Bar -YAxisStep 10 -XAxisStep 10
#Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "Great" -Type Scatter -YAxisStep 20 -XAxisStep 25
