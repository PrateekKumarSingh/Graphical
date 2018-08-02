Function Get-LinePlot {
    [cmdletbinding()]
    [alias("line")]
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
    #$up_upperhalf = [char]9581
    #$down_upperhalf = [char]9582
    #$up_lowerhalf = [char]9583
    #$down_lowerhalf = [char]9584
    #$upper_link = [char]9589
    #$lower_link = [char]9591
    #$link = '|'

    $leftlink = [char]9144
    $rightlink = [char]9145
    $up_lefthalf = [char]9163
    $down_lefthalf = [char]9164
    $up_righthalf = [char]9150
    $down_righthalf = [char]9151

    # Create a 2D Array to save datapoints  in a 2D format
    $NumOfRows = $difference/($Step) + 1
    $Array = New-Object 'object[,]' $NumOfRows,$NumOfDatapoints

    #For($i = 0;$i -lt $Datapoints.count;$i++){
    #    # Fit datapoint in a row, where, a row's data range = Total Datapoints / Step
    #    $RowIndex = [Math]::Ceiling($($Datapoints[$i]-$StartOfRange)/$Step)
    #    # use a half marker is datapoint falls in less than equals half of the step
    #    #$HalfMark = $Datapoints[$i]%$Step -in $(1..$HalfStep)
    #
    #    
    #    if($Datapoints[$i] -gt $Datapoints[$i-1]){
    #        $Array[($RowIndex),$i] = $up_righthalf           
    #        $increasing = $true
    #    }
    #    elseif ($Datapoints[$i] -lt $Datapoints[$i+1]){
    #        $Array[($RowIndex),$i] = $down_lefthalf
    #        $increasing = $false           
    #    }
    #    else{
    #        $Array[($RowIndex),$i] = '-'
    #    }
    #    if($increasing -eq $true){        
    #        # To get a bar fill all the same row indices of 2D array under and including datapoint
    #        For($j=0;$j -lt $RowIndex;$j++){
    #            #write-host "`$RowIndex:$RowIndex Data:$($Datapoints[$i]) `$i:$i `$j=$j `$Step:$Step Rows:$NumOfRows Cols:$NumOfDatapoints"
    #            $Array[$j,$i] = $leftlink
    #        }
    #    }elseif($increasing -eq $false){
    #        # To get a bar fill all the same row indices of 2D array under and including datapoint
    #        For($j=0;$j -lt $RowIndex;$j++){
    #            #write-host "`$RowIndex:$RowIndex Data:$($Datapoints[$i]) `$i:$i `$j=$j `$Step:$Step Rows:$NumOfRows Cols:$NumOfDatapoints"
    #            $Array[$j,$i] = $rightlink
    #        }
#
    #    }
    #}

    For($i = 0;$i -lt $Datapoints.count;$i++){
        # Fit datapoint in a row, where, a row's data range = Total Datapoints / Step
        $RowIndex = [Math]::Ceiling($($Datapoints[$i]-$StartOfRange)/$Step) 
        $RowIndexNextItem = [Math]::Ceiling($($Datapoints[$i+1]-$StartOfRange)/$Step) 

        # use a half marker is datapoint falls in less than equals half of the step
        $LowerHalf = $Datapoints[$i]%$Step -in $(1..$HalfStep)
        
        if($LowerHalf){
            $Array[$RowIndex,$i] = [char] 9148
        }else{
            $Array[$RowIndex,$i] = [char] 9146
        }
        
        # To get a bar fill all the same row indices of 2D array under and including datapoint
        #For($j=$RowIndex;$j -le $RowIndexNextItem;$j++){
        #    $Array[$j,$i] = $rightlink
        #}
        write-host "Row:$RowIndex; Next:$RowIndexNextItem" -ForegroundColor Cyan -NoNewline;

        if($RowIndex -gt $RowIndexNextItem){
            $RangeDiff = [math]::abs($RowIndex-$RowIndexNextItem-1)
            write-host " DOWN [$($RowIndex-1)-$($RowIndexNextItem+1)] RangeDiff: $RangeDiff" -ForegroundColor Green
            if($RangeDiff -notin 0,1){
                Foreach($j in $($RowIndex-1)..$($RowIndexNextItem+1)){
                    $Array[$j,$i] = $rightlink
                }
            }
        }elseif($RowIndex -lt $RowIndexNextItem){
            $RangeDiff = [math]::abs($RowIndex-$RowIndexNextItem-1)
            write-host " UP [$($RowIndex+1)-$($RowIndexNextItem-1)] RangeDiff: $RangeDiff" -ForegroundColor Green
            if($RangeDiff -notin 0,1){
                Foreach($j in $($RowIndex+1)..$($RowIndexNextItem-1)){
                    $Array[$j,$i] = $rightlink
                }
            }
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
