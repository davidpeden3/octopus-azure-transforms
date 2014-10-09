Write-Host "cleaning up temp files"
Remove-Item * -exclude *.cspkg,*.cscfg -recurse

Write-Host "done!"