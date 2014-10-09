Write-Host "Repacking Azure Web Package"

$role = "OctopusVariableSubstitutionTester"
$rolePath = "webrole/approot"
$webPath = "webrole/sitesroot/0"
$cspackPath = "C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v2.3\bin\cspack.exe"

& $cspackPath "ServiceDefinition.csdef" "/out:Azure.ccproj.cspkg" "/role:$role;$rolePathOctopusVariableSubstitutionTester.dll" "/rolePropertiesFile:$role;cspackproperties.txt" "/sites:$role;Web;$webPath" "/sitePhysicalDirectories:$role;Web;$webPath"