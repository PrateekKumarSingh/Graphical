Function Get-ScatterPlot {
    [cmdletbinding()]
    [alias("scatter")]
    Param(
            # Parameter help description
            [Parameter(Mandatory=$true)]
            [int[]] $Datapoints,
            [int] $StartOfRange,
            [int] $EndofRange,
            [int] $Step = 10
            #[ValidateSet("square","dot","triangle")] [String] $Marker = 'dot'
    )

    #$MarkerTable =  @{
    #    square = [char] 9642
    #    dot = [char] 9679
    #    triangle = [char] 9650 # 9652
    #}
    #$Marker = $MarkerTable[$Marker]

    # Create a 2D Array to save datapoints  in a 2D format
    $Difference = $EndofRange - $StartOfRange
    $NumOfRows = $difference/($Step) + 1
    $NumOfDatapoints = $Datapoints.Count
    $Array = New-Object 'object[,]' ($NumOfRows),$NumOfDatapoints


    For($i = 0;$i -lt $Datapoints.count;$i++){
        # Fit datapoint in a row, where, a row's data range = Total Datapoints / Step
        $RowIndex = [Math]::Ceiling($($Datapoints[$i]-$StartOfRange)/$Step) 

        # use a half marker is datapoint falls in less than equals half of the step
        $LowerHalf = $Datapoints[$i]%$Step -in $(1..$HalfStep)
        
        if($LowerHalf){
            $Array[$RowIndex,$i] = [char] 9604
        }else{
            $Array[$RowIndex,$i] = [char] 9600
        }
        
        # To get a bar fill all the same row indices of 2D array under and including datapoint
        #For($j=0;$j -lt $RowIndex;$j++){
        #    $Array[$j,$i] = $Marker
        #}
    }

    # return the 2D array of plots
    return ,$Array
}
