Function CenterAlignString ($String, $Length) {
        $Padding = [math]::Round( $Length/2 + [math]::round( $String.length/2)  )
        return $String.PadLeft($Padding)
}
Function CenterAlignStringReturnIndices ($String, $Length) {
        $StartIdx = [Math]::Round(($Length + ($String.Length -1)) / 2 )
        $EndIdx = $StartIdx - ($String.Length -1)
        return $StartIdx, $EndIdx
}

Function Write-Graph($YAxisLabelAlphabet, $YAxisLabel, $Row, $RowColor, $LabelColor)
{
    Write-Host $YAxisLabelAlphabet -ForegroundColor $LabelColor -NoNewline
    Write-Host "$($YAxisLabel.tostring().PadLeft($LengthOfMaxYAxisLabel+2) + [Char]9508)" -NoNewline
    ##Write-Host "$YAxisLabel|" -NoNewline
    Write-Host $Row -ForegroundColor $RowColor
}
