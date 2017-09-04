<#
.SYNOPSIS
Draws graph in the Powershell console

.DESCRIPTION
Consumes datapoints and draws colored coded fully customizable graph in the Powershell console

.PARAMETER Datapoints
Array of data points which is to be plotted on the graph

.PARAMETER XAxisTitle
Label on the X-Axis

.PARAMETER YAxisTitle
Label on the Y-Axis

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
            [Parameter(Mandatory=$true)]
            [int[]] $Datapoints,
            [String] $XAxisTitle = 'X-Axis',
            [String] $YAxisTitle = 'Y Axis'
    )
            
    $NumOfDatapoints = $Datapoints.Count
    $NumOfLabelsOnYAxis = 10
    $XAxis = "   "+"-"*($NumOfDatapoints+3) 
    $YAxisTitleAlphabetCounter = 0
    $YAxisTitleStartIdx = 1
    $YAxisTitleEndIdx = $YAxisTitleStartIdx + $YAxisTitle.Length -1
    
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
    $Count = 0
    $Datapoints | ForEach-Object {
        $r = [Math]::Floor($_/10)
        $Array[$r,$Count] = [char] 9608
        1..$R | ForEach-Object {$Array[$_,$Count] = [char] 9608}
        $Count++
    }
 
    # Draw graph
    For($i=10;$i -gt 0;$i--){
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

#$Datapoints = (1..100|Get-Random -Count 50)
#Show-Graph -Datapoints $Datapoints -XAxisTitle "Avg. CPU utilization" -YAxisTitle "Percentage"
