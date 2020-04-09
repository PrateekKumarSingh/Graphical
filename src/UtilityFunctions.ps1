Function CenterAlignString ($String, $Length) {
        $Padding = [math]::Round( $Length/2 + [math]::round( $String.length/2)  )
        return $String.PadLeft($Padding)
}
Function CenterAlignStringReturnIndices ($String, $Length) {
        $StartIdx = [Math]::Round(($Length + ($String.Length -1)) / 2 )
        $EndIdx = $StartIdx - ($String.Length -1)
        return $StartIdx, $EndIdx
}

Function Write-Graph($YAxisLabelAlphabet, $YAxisLabel, $Row, $RowColor, $LabelColor, $OutFile)
{
    Write-Host -Object $([char]9474) -NoNewline
    Write-Host -Object $YAxisLabelAlphabet -ForegroundColor $LabelColor -NoNewline
    Write-Host -Object "$($YAxisLabel.tostring().PadLeft($LengthOfMaxYAxisLabel+2) + [Char]9508)" -NoNewline
    ##Write-Host "$YAxisLabel|" -NoNewline
    Write-Host -Object $Row -ForegroundColor $RowColor -NoNewline
    Write-Host -Object "  $([char]9474)"

    if($OutFile){
        Out-File -InputObject "$([char]9474)" -NoNewline -FilePath $OutFile -Append -Encoding unicode
        Out-File -InputObject $YAxisLabelAlphabet  -NoNewline -FilePath $OutFile -Append -Encoding unicode
        Out-File -InputObject "$($YAxisLabel.tostring().PadLeft($LengthOfMaxYAxisLabel+2) + [Char]9508)" -NoNewline -FilePath $OutFile -Append -Encoding unicode
        Out-File -InputObject $Row -NoNewline -FilePath $OutFile -Append -Encoding unicode
        Out-File -InputObject "  $([char]9474)" -FilePath $OutFile -Append -Encoding unicode
    }
}
