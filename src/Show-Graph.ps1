<#
.SYNOPSIS
Draws graph in the Powershell console

.DESCRIPTION
Consumes datapoints and draws colored coded fully customizable graph in the Powershell console

.PARAMETER Datapoints
Array of data points which is to be plotted on the graph

.PARAMETER XAxisTitle
Defines text label on x-axis

.PARAMETER YAxisTitle
Defines text label on x-axis

.PARAMETER GraphTitle
Title of the graph

.PARAMETER XAxisStep
Define value of step on x-axis

.PARAMETER YAxisStep
Define value of step on y-axis

.PARAMETER Type
Choose type of the graph [bar, line, scatter]

.PARAMETER ColorMap
Hash table that defines the range of color codes

.PARAMETER HorizontalLines
Add horizontal lines to the graph area

.EXAMPLE
$data = 1..100 | Get-Random -Count 50
Show-Graph -Datapoints $Data -GraphTitle 'CPU'

.EXAMPLE
$data = 1..100 | Get-Random -Count 50
Show-Graph -Datapoints $Data -Type Line

.EXAMPLE
$data = 1..100 | Get-Random -Count 50
Show-Graph -Datapoints $Data -Type Scatter

.EXAMPLE
$data = 1..100 | Get-Random -Count 50
Show-Graph -Datapoints $Data -YAxisTitle "Percentage" -XAxistitle "Time"

.NOTES
Blog: https://RidiCurious.com/
Github: https://github.com/PrateekKumarSingh/Graphical
Author: https://twitter.com/SinghPrateik

Features and Benefits:
- Independent of PowerShell version, and Works on PowerShell Core (Windows\Linux)
- Color-coded output depending upon the Value of data point
- Colors codes can be customized by passing a color-map hash table
- Custom X an Y-Axis labels
- Graph in console is independent and fully customizable, not like Task Manager (Performance Tab)
- Could be incorporated in Powershell scripts
- Can consume data points generated during script run or Pre stored data like in a file or database.
#>
Function Show-Graph {
    [cmdletbinding()]
    [alias("Graph")]
    Param(
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline)] [int[]] $Datapoints,
            [String] $XAxisTitle,
            [String] $YAxisTitle,
            [String] $GraphTitle = 'Untitled',
            [ValidateScript({
                if($_ -le 5){
                Throw "Can not set XAxisStep less than or equals to 5"
                }
                else{
                    $true
                }
            })] [Int] $XAxisStep = 10,
            [Int] $YAxisStep = 10,
            [ValidateSet("Bar","Scatter","Line")] [String] $Type = 'Bar',
            [Hashtable] $ColorMap,
            [Switch] $HorizontalLines
    )

    # graph boundary marks
    $TopLeft = [char]9484
    $BottomLeft = [char]9492
    $TopRight = [char]9488
    $BottomRight = [char]9496
    $VerticalEdge = [char]9474
    $TopEdge = $BottomEdge = [char]9472

    # Calculate Max, Min and Range of Y axis
    $NumOfDatapoints = $Datapoints.Count
    $Metric = $Datapoints | Measure-Object -Maximum -Minimum
    $EndofRange = $Metric.Maximum + ($YAxisStep - $Metric.Maximum % $YAxisStep)
    $StartOfRange = $Metric.Minimum - ($Metric.Minimum % $YAxisStep)
    $difference =  $EndofRange - $StartOfRange
    $NumOfRows = $difference/($YAxisStep)

    # Calculate label lengths
    $NumOfLabelsOnYAxis = $NumOfRows
    $LengthOfMaxYAxisLabel = (($Datapoints | Measure-Object -Maximum).Maximum).tostring().length
    
    $YAxisTitleAlphabetCounter = 0
    $YAxisTitleStartIdx, $YAxisTitleEndIdx = CenterAlignStringReturnIndices -String $YAxisTitle -Length $NumOfRows
    
    If($YAxisTitle.Length -gt $NumOfLabelsOnYAxis){
        Write-Warning -Message "No. Alphabets in YAxisTitle [$($YAxisTitle.Length)] can't be greator than no. of Labels on Y-Axis [$NumOfLabelsOnYAxis]"
        Write-Warning -Message "YAxisTitle will be cropped"
    }
    
    # Create a 2D Array to save datapoints  in a 2D format
    switch($Type){
        'Bar'       {$Array = Get-BarPlot -Datapoints $Datapoints -Step $YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
        'Scatter'   {$Array = Get-ScatterPlot -Datapoints $Datapoints -Step $YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
        'Line'      {$Array = Get-LinePlot -Datapoints $Datapoints -Step $YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
    }
    
    # Preparing the step markings on the X-Axis
    $Increment = $XAxisStep
    $XAxisLabel = " " * ($LengthOfMaxYAxisLabel + 4)
    $XAxis = " " * ($LengthOfMaxYAxisLabel + 3) + [char]9492
    
    For($Label =1;$Label -le $NumOfDatapoints;$Label++){
        if ([math]::floor($Label/$XAxisStep) ){
            $XAxisLabel +=  $Label.tostring().PadLeft($Increment)
            $XAxis += ([char]9516).ToString()
            $XAxisStep+=$Increment
        }
        else{
            $XAxis += [Char]9472
        }
    }

    # calculate boundaries of the graph
    $TopBoundaryLength = $XAxis.Length - $GraphTitle.Length
    $BottomBoundaryLength = $XAxis.Length + 2
    
    # draw top boundary
    [string]::Concat($TopLeft," ",$GraphTitle," ",$([string]$TopEdge * $TopBoundaryLength),$TopRight)
    [String]::Concat($VerticalEdge,$(" "*$($XAxis.length+2)),$VerticalEdge) # extra line to add space between top-boundary and the graph
    
    # draw the graph
    For($i=$NumOfRows;$i -gt 0;$i--){
        $Row = ''
        For($j=0;$j -lt $NumOfDatapoints;$j++){
            $Cell = $Array[$i,$j]
            if([String]::IsNullOrWhiteSpace($Cell)){
                if($AddHorizontalLines){
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
        
        $YAxisLabel = $StartOfRange + $i*$YAxisStep
        
        
        # add Y-Axis title alphabets if it exists in a row
        If($i -in $YAxisTitleStartIdx..$YAxisTitleEndIdx -and $YAxisTitle){
            $YAxisLabelAlphabet = $YAxisTitle[$YAxisTitleAlphabetCounter]
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
    
    # draw bottom boundary
    $XAxisLabel +=" "*($XAxis.Length-$XAxisLabel.Length) # to match x-axis label length with x-axis length
    [String]::Concat($VerticalEdge,$XAxis,"  ",$VerticalEdge) # Prints X-Axis horizontal line
    [string]::Concat($VerticalEdge,$XAxisLabel,"  ",$VerticalEdge) # Prints X-Axis step labels

    
    if(![String]::IsNullOrWhiteSpace($XAxisTitle)){
        # Position the x-axis label at the center of the axis
        $XAxisTitle = " "*$LengthOfMaxYAxisLabel + (CenterAlignString $XAxisTitle $XAxis.Length)        
        Write-Host -Object $VerticalEdge -NoNewline
        Write-Host -Object $XAxisTitle -ForegroundColor DarkYellow -NoNewline # Prints XAxisTitle
        Write-Host -Object $(" "*$(($LengthOfMaxYAxisLabel + $XAxis.length) - $XAxisTitle.Length - 2)) $VerticalEdge
    }
    
    # bottom boundary
    [string]::Concat($BottomLeft,$([string]$BottomEdge * $BottomBoundaryLength),$BottomRight)
    
}

#$Datapoints = (211..278|Get-Random -Count 50)
#Show-Graph -Datapoints $Datapoints -GraphTitle "Avg. CPU utilization" -YAxisTitle "Percent" `
#    -Type Bar -YAxisStep 10 -XAxisStep 10 -AddHorizontalLines -ColorMap @{230 = 'red'; 250 = 'cyan'; 270 = 'green'}
#Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "data a lot" `
#    -Type Scatter -YAxisStep 10 -XAxisStep 25 -AddHorizontalLines -ColorMap @{220 = 'red'; 240 = 'cyan'; 270 = 'green'; 290="Blue"}
