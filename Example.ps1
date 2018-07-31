Import-Module Graphical
$Datapoints = (21..278|Get-Random -Count 50)
Show-Graph -Datapoints $Datapoints -GraphTitle "Avg. CPU utilization" -YAxisTitle "Percent" `
-Type Bar -YAxisStep 30 -XAxisStep 10
Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "Great" `
-Type Scatter -YAxisStep 25 -XAxisStep 10 -HorizontalLines


9600, 9604, 9632, 9642, 9679, 9726 | ForEach-Object{write-host $([char]$_) ' - ' $_}

9000..10000 | ForEach-Object{write-host $([char]$_) ' - ' $_}

9150,9151, 9163, 9164| ForEach-Object{write-host $([char]$_) ' - ' $_}

$TopLeft = [char]9150
$BottomLeft = [char]9151
$TopRight = [char]9163
$BottomRight = [char]9164
$VerticalEdge = [char]9145
$TopEdge = [char]9620
$BottomEdge = [char]9601


$obj = [Graph]::new()
$obj.YAxisStep = 30
$obj.XAxisStep = 10
$obj.Plot($Datapoints,'Bar',$null,$null)
$obj.Plot($Datapoints,'Scatter',$null,$true)
