class Graph {
    # properties

    [String] $XAxisTitle = 'Label X-Axis'
    [String] $YAxisTitle = 'Y Axis'
    [String] $GraphTitle = 'Untitled'
    [Int] $XAxisStep = 10
    [Int] $YAxisStep = 10

    # constructor

    Plot ([int[]] $Datapoints, [String] $Type = 'Bar', [Hashtable] $ColorMap, [bool] $HorizontalLines)
    {

        $Title = $this.GraphTitle
        $Title_x = $this.XAxisTitle
        $Title_y = $this.YAxisTitle

        # Calculate Max, Min and Range of Y axis
        $NumOfDatapoints = $Datapoints.Count
        $Metric = $Datapoints | Measure-Object -Maximum -Minimum
        $EndofRange = $Metric.Maximum + ($this.YAxisStep - $Metric.Maximum % $this.YAxisStep)
        $StartOfRange = $Metric.Minimum - ($Metric.Minimum % $this.YAxisStep)
        $difference =  $EndofRange - $StartOfRange
        $NumOfRows = $difference/($this.YAxisStep)

        # Calculate label lengths
        $NumOfLabelsOnYAxis = $NumOfRows
        $LengthOfMaxYAxisLabel = (($Datapoints | Measure-Object -Maximum).Maximum).tostring().length
        #$XAxis = " " * $($LengthOfMaxYAxisLabel + 3) + [char]9492 + ([char]9516).ToString() * $NumOfDatapoints

        $YAxisTitleAlphabetCounter = 0
        $YAxisTitleStartIdx, $YAxisTitleEndIdx = CenterAlignStringReturnIndices -String $Title_y -Length $NumOfRows
        #$YAxisTitleStartIdx = [Math]::Round(($NumOfRows + ($YAxisTitle.Length -1)) / 2 )
        #$YAxisTitleEndIdx = $YAxisTitleStartIdx - ($YAxisTitle.Length -1)

        If($Title_y.Length -gt $NumOfLabelsOnYAxis){
            Write-Warning "No. Alphabets in YAxisTitle [$($Title_y.Length)] can't be greator than no. of Labels on Y-Axis [$NumOfLabelsOnYAxis]"
            Write-Warning "YAxisTitle will be cropped"
        }

        # prepare chart boundaries
        $TopLeft = [char]9150
        $BottomLeft = [char]9151
        $TopRight = [char]9163
        $BottomRight = [char]9164
        $VerticalEdge = [char]9145
        $TopEdge = [char]9620
        $BottomEdge = [char]9601

        #Write-Host $TopLeft $Array

        # Create a 2D Array to save datapoints  in a 2D format
        $Array = @()
        switch($Type){
            'Bar'       {$Array = Get-BarPlot -Datapoints $Datapoints -Step $this.YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
            'Scatter'   {$Array = Get-ScatterPlot -Datapoints $Datapoints -Step $this.YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
        }

        # Preparing the step markings on the X-Axis
        $Increment = $this.XAxisStep
        $XAxisLabel = " " * ($LengthOfMaxYAxisLabel + 4)
        $XAxis = " " * ($LengthOfMaxYAxisLabel + 3) + [char]9492

        For($Label =1;$Label -le $NumOfDatapoints;$Label++){
            if ([math]::floor($Label/$this.XAxisStep) ){
                $XAxisLabel +=  $Label.tostring().PadLeft($Increment)
                $XAxis += ([char]9516).ToString()
                $this.XAxisStep+=$Increment
            }
            else{
                $XAxis += [Char]9472
            }
        }

        $Title_x = " "*$LengthOfMaxYAxisLabel + (CenterAlignString $Title_x $XAxis.Length)


        For($i=$NumOfRows;$i -gt 0;$i--){
            $Row = ''
            For($j=0;$j -lt $NumOfDatapoints;$j++){
                $Cell = $Array[$i,$j]
                if([String]::IsNullOrWhiteSpace($Cell)){
                    if($HorizontalLines){
                        $String = [Char]9472
                    }
                    else{
                        $String = ' '
                    }
                    #$String = [Char]9532
                }else{
                    $String = $Cell
                }
                $Row = [string]::Concat($Row,$String)
            }
            
            $YAxisLabel = $StartOfRange + $i*$this.YAxisStep
            
            
            If($i -in $YAxisTitleStartIdx..$YAxisTitleEndIdx){
                $YAxisLabelAlphabet = $Title_y[$YAxisTitleAlphabetCounter]
                $YAxisTitleAlphabetCounter++
            }
            else {
                $YAxisLabelAlphabet = ' '
            }
            
    
            If($ColorMap){
    
                $Keys = $ColorMap.Keys| Sort-Object
                $LowerBound = $StartOfRange
                $Map=@()
    
                $Map += For($k=0;$k -lt $Keys.count;$k++){
                    [PSCustomObject]@{
                        LowerBound  = $LowerBound
                        UpperBound  = $Keys[$k]
                        Color       = $ColorMap[$Keys[$k]]
                    }
                    $LowerBound = $Keys[$k]+1
                }
                
                $Color = $Map.ForEach({
                    if($YAxisLabel -in $_.LowerBound..$_.UpperBound){
                        $_.Color
                    }
                })
    
                if ([String]::IsNullOrEmpty($Color)) {$Color = "White"}
                
                Write-Graph $YAxisLabelAlphabet $YAxisLabel $Row $Color 'DarkYellow'
    
            }
            else{
                # Default coloring mode divides the datapoints in percentage range
                # and color code them automatically 
                # i.e, 
                # 1-40% -> Green
                # 41-80% -> Yellow
                # 81-100% -> Red
    
                $RangePercent = $i/$NumOfRows * 100
                # To color the graph depending upon the datapoint value
                If ($RangePercent -gt 80) {
                    Write-Graph $YAxisLabelAlphabet $YAxisLabel $Row 'Red' 'DarkYellow'
                }
                elseif($RangePercent-le 80 -and $RangePercent -gt 40) {
                    Write-Graph $YAxisLabelAlphabet $YAxisLabel $Row 'Yellow' 'DarkYellow' 
                }
                elseif($RangePercent -le 40 -and $RangePercent -ge 1) {
                    Write-Graph $YAxisLabelAlphabet $YAxisLabel $Row 'Green' 'DarkYellow'
                }
                else {
                    #Write-Host "$YAxisLabel|"
                    #Write-Host "$($YAxisLabel.PadLeft($LengthOfMaxYAxisLabel+2))|"
                }
            }
            
        }
        
        Write-Host $XAxis # Prints X-Axis horizontal line
        Write-Host $XAxisLabel # Prints X-Axis horizontal line
        Write-Host $Title_x -ForegroundColor DarkYellow # Prints XAxisTitle
        if($Title){
            $Title = " " * $LengthOfMaxYAxisLabel + (CenterAlignString "[$Title]" $XAxis.Length)
            Write-Host $Title # Prints  graph title
        }
    }



}
