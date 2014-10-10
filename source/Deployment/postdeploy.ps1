# $outputPackageName - the name of the final cspkg

Write-Host "cleaning up temp files"
Remove-Item * -exclude $outputPackageName,ServiceConfiguration.$OctopusEnvironmentName.cscfg -recurse

Write-Host "done!"