# Dot Sourcing files

Get-ChildItem "$PSScriptRoot\Source\" | ForEach-Object {
   . $_.FullName
}

# Exporting the members and their aliases
Export-ModuleMember -Function "Show-Graph" -Alias 'Graph'

#$Datapoints = (21..278|Get-Random -Count 50)
#Show-Graph -Datapoints $Datapoints -GraphTitle "Avg. CPU utilization" -YAxisTitle "Percent" -Type Bar -YAxisStep 10 -XAxisStep 10
#Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "Great" -Type Scatter -YAxisStep 20 -XAxisStep 25
