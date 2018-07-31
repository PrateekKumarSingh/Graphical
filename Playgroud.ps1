Import-Module c:\data\powershell\repository\Graphical\Graphical.psm1 -Verbose
$Datapoints = (0..100|Get-Random -Count 50)

Show-Graph -Datapoints $Datapoints -GraphTitle "CPU" -Type Line
Show-Graph -Datapoints $Datapoints -GraphTitle 'Memory' -Type Scatter

9600, 9604, 9632, 9642, 9679, 9726 | ForEach-Object{write-host $([char]$_) ' - ' $_}

9400..9600 | ForEach-Object{write-host $([char]$_) ' - ' $_}

# PI chart
10250..10495 | ForEach-Object{write-host $([char]$_) ' - ' $_}

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


[char]10495

$radius = 5
$diameter = $radius*2

$Array = New-Object 'object[,]' $diameter,$diameter


For($i = 0;$i -lt $Datapoints.count;$i++){
    # Fit datapoint in a row, where, a row's data range = Total Datapoints / Step
    $RowIndex = [Math]::Ceiling($($Datapoints[$i]-$StartOfRange)/$Step)
    # use a half marker is datapoint falls in less than equals half of the step
    $HalfMark = $Datapoints[$i]%$Step -in $(1..$HalfStep)
    
    if($HalfMark){
        $Array[($RowIndex),$i] = [char] 9604
    }else{
        $Array[($RowIndex),$i] = $Marker
    }
    
    # To get a bar fill all the same row indices of 2D array under and including datapoint
    For($j=0;$j -lt $RowIndex;$j++){
        #write-host "`$RowIndex:$RowIndex Data:$($Datapoints[$i]) `$i:$i `$j=$j `$Step:$Step Rows:$NumOfRows Cols:$NumOfDatapoints"
        $Array[$j,$i] = $Marker
    }
}

# return the 2D array of plots
return ,$Array

for($y=0; $y -lt $diameter; $y++)
{
    $slope = $radius*$radius-$y*$y
    if($slope -lt 0){
        $slope = $diameter - [math]::Sqrt([math]::Abs($slope))
    }
    else {
        $slope = [math]::Sqrt($slope)
    }
    #$(" "*$x) + $slope
    #$x= [math]::Sqrt($radius*$radius-$y*$y)
    #$x= [math]::Sqrt()
    [string]::Concat('[',$slope,',',$y,']')
    [string]::Concat($(" "*$slope),"*")
}   
    $half_row_width
    for($x=-$half_row_width; $x -lt $half_row_width; $x++){
        WritePixel(centre_x+x, centre_$y+$y, colour);
    }
}


for($y=0; $y -lt $diameter; $y++)
{   
    for($x=0; $y -lt $radius; $x++){
        $pixel = [string]::Concat(" "*$($radius+$x),"*")
        [string]::Concat('[',$(slope),',',$y,']')
    }
    [string]::Concat($(" "*$slope),"*")
} 
