Function Get-BarPlot {
    [cmdletbinding()]
    [alias("bar")]
    Param(
            # Parameter help description
            [Parameter(Mandatory=$true)]
            [int[]] $Datapoints,
            [int] $StartOfRange,
            [int] $EndofRange,
            [int] $Step = 10
    )
    $Difference = $EndofRange - $StartOfRange

    $NumOfDatapoints = $Datapoints.Count
    $HalfStep = [Math]::Ceiling($Step/2)
    $Marker = [char] 9608

    # Create a 2D Array to save datapoints  in a 2D format
    $NumOfRows = $difference/($Step) + 1
    $Array = New-Object 'object[,]' $NumOfRows,$NumOfDatapoints

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
}

#
#$Array = Get-BarPlot $datapoints -Step 5
#
#For($i=$Step;$i -ge 0;$i--){
#    $Row = ''
#        For($j=0;$j -lt $NumOfDatapoints;$j++){
#            $Cell = $Array[$i,$j]
#             $String = If([String]::IsNullOrWhiteSpace($Cell)){' '}else{$Cell}
#             $Row = [string]::Concat($Row,$String)          
#        }
#
#    Write-Host $Row
#}
