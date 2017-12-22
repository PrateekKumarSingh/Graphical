<#
.SYNOPSIS
Draws graph in the Powershell console

.DESCRIPTION
Consumes datapoints and draws colored coded fully customizable graph in the Powershell console

.PARAMETER Datapoints
Array of data points which is to be plotted on the graph

.PARAMETER XAxisTitle
Parameter description

.PARAMETER YAxisTitle
Parameter description

.PARAMETER GraphTitle
Parameter description

.PARAMETER XAxisStep
Parameter description

.PARAMETER YAxisStep
Parameter description

.PARAMETER Type
Parameter description

.PARAMETER ColorMap
Parameter description

.PARAMETER AddHorizontalLines
Parameter description

.EXAMPLE
Show-Graph -Datapoints $Datapoints

.EXAMPLE
Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "Percentage"

.NOTES
Blog: https://geekeefy.wordpress.com/
Author: https://twitter.com/SinghPrateik
Features and Benefits:
* Color-coded output depending upon the Value of Datapoint
* Custom X an Y-Axis labels
* Graph in console is independent and fully customizable, not like Task Manager (Performance Tab)
* Could be incorporated in Powershell scripts
* Can consume datapoints generated during script run or Pre stored data like in a file or database.

#>
Function Show-Graph {
    [cmdletbinding()]
    [alias("Graph")]
    Param(
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline)] [int[]] $Datapoints,
            [String] $XAxisTitle = 'X-Axis',
            [String] $YAxisTitle = 'Y Axis',
            [String] $GraphTitle,
            [ValidateScript({
                if($_ -le 5){
                Throw "Can not set XAxisStep less than or equals to 5"
                }
                else{
                    $true
                }
            })] [Int] $XAxisStep = 10,
            [Int] $YAxisStep = 10,
            [ValidateSet("Bar","Scatter")] [String] $Type = 'Bar',
            [Hashtable] $ColorMap,
            [Switch] $AddHorizontalLines
    )
            
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
    #$XAxis = " " * $($LengthOfMaxYAxisLabel + 3) + [char]9492 + ([char]9516).ToString() * $NumOfDatapoints
    
    $YAxisTitleAlphabetCounter = 0
    $YAxisTitleStartIdx, $YAxisTitleEndIdx = CenterAlignStringReturnIndices -String $YAxisTitle -Length $NumOfRows
    #$YAxisTitleStartIdx = [Math]::Round(($NumOfRows + ($YAxisTitle.Length -1)) / 2 )
    #$YAxisTitleEndIdx = $YAxisTitleStartIdx - ($YAxisTitle.Length -1)
    
    If($YAxisTitle.Length -gt $NumOfLabelsOnYAxis){
        Write-Warning "No. Alphabets in YAxisTitle [$($YAxisTitle.Length)] can't be greator than no. of Labels on Y-Axis [$NumOfLabelsOnYAxis]"
        Write-Warning "YAxisTitle will be cropped"
    }
    
    
    # Create a 2D Array to save datapoints  in a 2D format
    switch($Type){
        'Bar'       {$Array = Get-BarPlot -Datapoints $Datapoints -Step $YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
        'Scatter'   {$Array = Get-ScatterPlot -Datapoints $Datapoints -Step $YAxisStep -StartOfRange $StartOfRange -EndofRange $EndofRange }
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
    
    $XAxisTitle = " "*$LengthOfMaxYAxisLabel + (CenterAlignString $XAxisTitle $XAxis.Length)
    #"`$YAxisTitleStartIdx:$YAxisTitleStartIdx `$YAxisTitleEndIdx:$YAxisTitleEndIdx `$NumOfRows:$NumOfRows"
    
    # Drawing the graph
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
        
        
        If($i -in $YAxisTitleStartIdx..$YAxisTitleEndIdx){
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
    
    Write-Host $XAxis # Prints X-Axis horizontal line
    Write-Host $XAxisLabel # Prints X-Axis horizontal line
    Write-Host $XAxisTitle -ForegroundColor DarkYellow # Prints XAxisTitle
    if($GraphTitle){        
        $GraphTitle = " " * $LengthOfMaxYAxisLabel + (CenterAlignString "[$GraphTitle]" $XAxis.Length)
        Write-Host $GraphTitle # Prints XAxisTitle
    }
}

#$Datapoints = (211..278|Get-Random -Count 50)
#Show-Graph -Datapoints $Datapoints -GraphTitle "Avg. CPU utilization" -YAxisTitle "Percent" `
#    -Type Bar -YAxisStep 10 -XAxisStep 10 -AddHorizontalLines -ColorMap @{230 = 'red'; 250 = 'cyan'; 270 = 'green'}
#Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "data a lot" `
#    -Type Scatter -YAxisStep 10 -XAxisStep 25 -AddHorizontalLines -ColorMap @{220 = 'red'; 240 = 'cyan'; 270 = 'green'; 290="Blue"}
