Function Write-Graph($YAxisLabelAlphabet, $YAxisLabel, $Row, $RowColor, $LabelColor){
    Write-Host $YAxisLabelAlphabet -ForegroundColor $LabelColor -NoNewline
    Write-Host "$YAxisLabel|" -NoNewline
    Write-Host $Row -ForegroundColor $RowColor
}
