Import-Module cspack-utilities

Write-Host "unzip the cspkg file"
Unzip "Azure.ccproj.cspkg" "azurePackage"

Write-Host "unzip the cssx file"
Unzip (Get-Item (join-path -path "azurePackage" -childPath "OctopusVariableSubstitutionTester*.cssx")) "azurePackage\webrole"

Write-Host "copy transformed web.config into approot"
Copy-Item web.config .\azurepackage\webrole\approot

Write-Host "copy transformed web.config into sitesroot\0"
Copy-Item web.config .\azurepackage\webrole\sitesroot\0

Write-Host "create package"
$role = "OctopusVariableSubstitutionTester"
$rolePath = "azurepackage/webrole/approot"
$webPath = "azurepackage/webrole/sitesroot/0"
$cspackPath = "C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v2.3\bin\cspack.exe"

Write-Host "executing the following cspack command:"
Write-Host $cspackPath "ServiceDefinition.csdef" "/out:Azure.ccproj.cspkg" "/role:$role;$rolePath;OctopusVariableSubstitutionTester.dll" "/rolePropertiesFile:$role;roleproperties.txt" "/sites:$role;Web;$webPath" "/sitePhysicalDirectories:$role;Web;$webPath"
& $cspackPath "ServiceDefinition.csdef" "/out:Azure.ccproj.cspkg" "/role:$role;$rolePath;OctopusVariableSubstitutionTester.dll" "/rolePropertiesFile:$role;roleproperties.txt" "/sites:$role;Web;$webPath" "/sitePhysicalDirectories:$role;Web;$webPath"
generatePackage "OctopusVariableSubstitutionTester" "azurepackage/webrole" "Web"
