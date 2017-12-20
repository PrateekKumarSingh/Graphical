Function Get-BarGraph {
    [cmdletbinding()]
    [alias("bar")]
    Param(
            # Parameter help description
            [Parameter(Mandatory=$true)]
            [int[]] $Datapoints,
            [int] $Step = 10,
            [String] $XAxisTitle = 'X-Axis',
            [String] $YAxisTitle = 'Y Axis'
    )
        
    $NumOfDatapoints = $Datapoints.Count
    $NumOfLabelsOnYAxis = $Step
    $XAxis = "   "+"-"*($NumOfDatapoints+3) 
    $YAxisTitleAlphabetCounter = 0
    $YAxisTitleStartIdx = 1
    $YAxisTitleEndIdx = $YAxisTitleStartIdx + $YAxisTitle.Length -1
    $HalfStep = $Step/2
    $Marker = [char] 9608

    If($YAxisTitle.Length -gt $NumOfLabelsOnYAxis){
        Write-Warning "No. Alphabets in YAxisTitle [$($YAxisTitle.Length)] can't be greator than no. of Labels on Y-Axis [$NumOfLabelsOnYAxis]"
        Write-Warning "YAxisTitle will be cropped"
    }

    If($XAxisTitle.Length -gt $XAxis.length-3){
        $XAxisLabel = "   "+$XAxisTitle
    }else{
        $XAxisLabel = "   "+(" "*(($XAxis.Length - $XAxisTitle.Length)/2))+$XAxisTitle
    }

    # Create a 2D Array to save datapoints  in a 2D format
    $Array = New-Object 'object[,]' ($NumOfLabelsOnYAxis+1),$NumOfDatapoints

    For($i = 0;$i -lt $Datapoints.count;$i++){
        # Fit datapoint in a row, where, a row's data range = Total Datapoints / Step
        $RowIndex = [Math]::Ceiling($Datapoints[$i]/$Step) 

        # use a half marker is datapoint falls in less than equals half of the step
        $HalfMark = $Datapoints[$i]%$Step -in $(1..$HalfStep)
        
        if($HalfMark){
            $Array[$RowIndex,$i] = [char] 9604
        }else{
            $Array[$RowIndex,$i] = $Marker
        }
        
        # To get a bar fill all the same row indices of 2D array under and including datapoint
        For($j=0;$j -lt $RowIndex;$j++){
            $Array[$j,$i] = $Marker
        }
    }

    # Draw graph
    For($i=$Step;$i -gt 0;$i--){
    $Row = ''
        For($j=0;$j -lt $NumOfDatapoints;$j++){
            $Cell = $Array[$i,$j]
             $String = If([String]::IsNullOrWhiteSpace($Cell)){' '}else{$Cell}
             $Row = [string]::Concat($Row,$String)          
        }

    $YAxisLabel = $i*10

    # Condition to fix the spacing issue of a 3 digit vs 2 digit number [like 100 vs 90]  on the Y-Axis
    If("$YAxisLabel".length -lt 3){$YAxisLabel = (" "*(3-("$YAxisLabel".length)))+$YAxisLabel}

    If($i -in $YAxisTitleStartIdx..$YAxisTitleEndIdx){
        $YAxisLabelAlphabet = $YAxisTitle[$YAxisTitleAlphabetCounter]+" "
        $YAxisTitleAlphabetCounter++
    }
    else {
        $YAxisLabelAlphabet = '  '
    }

    # To color the graph depending upon the datapoint value
    If ($i -gt 7) {Write-Host $YAxisLabelAlphabet -ForegroundColor DarkYellow -NoNewline  ;Write-Host "$YAxisLabel|" -NoNewline; Write-Host $Row -ForegroundColor Red}
    elseif ($i -le 7 -and $i -gt 4) {Write-Host $YAxisLabelAlphabet -ForegroundColor DarkYellow -NoNewline ;Write-Host "$YAxisLabel|" -NoNewline; Write-Host $Row -ForegroundColor Yellow}
    elseif($i -le 4 -and $i -ge 1) {Write-Host $YAxisLabelAlphabet -ForegroundColor DarkYellow -NoNewline ;Write-Host "$YAxisLabel|" -NoNewline; Write-Host $Row -ForegroundColor Green}
    else {Write-Host "$YAxisLabel|"}
    }

    $XAxis # Prints X-Axis horizontal line
    Write-Host $XAxisLabel -ForegroundColor DarkYellow # Prints XAxisTitle
}
