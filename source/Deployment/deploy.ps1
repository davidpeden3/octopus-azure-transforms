# load the assembly required
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")

function Unzip($zipFile, $destination)
{
	#Delete destination folder if it exists
	If (Test-Path $destination){
		Remove-Item $destination -Recurse
	}

	#Create the destination folder
	New-Item -ItemType directory -Force -Path $destination

	#Unzip
	[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $destination)
}

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
generatePackage "OctopusVariableSubstitutionTester", "azurepackage/webrole", "Azure.ccproj.cspkg"

function generatePackage($roleName, $roleBasePath, $outputPackageName)
{
	$cspackPath = 'C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v2.3\bin\cspack.exe'
	$serviceDefinitionPath = "ServiceDefinition.csdef"

	$out = "/out:$outputPackageName"
	$role = "/role:$roleName;$rolePath"
	$rolePropertiesFile = "/rolePropertiesFile:$roleName;roleproperties.txt"
	$sites = "/sites:$roleName;Web;$roleBasePath/approot"
	$sitePhysicalDirectories = "/sitePhysicalDirectories:$roleName;Web;$roleBasePath/sitesroot/0"

	# Build CSPKG file
	Write-Host "create package"
	#& $cspackPath $serviceDefinitionPath $out $role $rolePropertiesFile $sites $sitePhysicalDirectories
	Write-Host $cspackPath $serviceDefinitionPath $out $role $rolePropertiesFile $sites $sitePhysicalDirectories
}