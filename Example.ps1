Import-Module Graphical
$Datapoints = (21..278|Get-Random -Count 50)
Show-Graph -Datapoints $Datapoints -GraphTitle "Avg. CPU utilization" -YAxisTitle "Percent" `
-Type Bar -YAxisStep 30 -XAxisStep 10
Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "Great" `
-Type Scatter -YAxisStep 25 -XAxisStep 10 -HorizontalLines


9600, 9604, 9632, 9642, 9679, 9726 | ForEach-Object{write-host $([char]$_) ' - ' $_}

8000..9000 | ForEach-Object{write-host $([char]$_) ' - ' $_}

$obj = [Graph]::new()
$obj.Plot
$obj.Plot($Datapoints,"Avg. CPU utilization","Percent","Consumption",10,30,'Bar',$null,$null)
$obj.Plot($Datapoints,"Avg. CPU utilization","Percent","Consumption",10,30,'Scatter',$null,$null)