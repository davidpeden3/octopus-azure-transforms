# $azureProjectName - the name of the azure project containing the role
# $azureRoleName - the name of the role
# $azureSdkVersion - the version of the Azure SDK
# $azureSiteName - the name of the site for the role
# $outputPackageName - the name of the final cspkg
# $webProjectName - the name of the web project used by the role
# $workingDirectory - the temp folder where the packing occurs

[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")

function Unzip($zipFile, $destination)
{
	If (Test-Path $destination){
		Write-Host "remove $destination"
		Remove-Item $destination -Recurse
	}

	Write-Host "create $destination"
	New-Item -ItemType directory -Force -Path $destination

	Write-Host "unzip contents of $zipFile into $destination"
	[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $destination)
}

function Generate-Package($azureSdkVersion, $roleName, $rolePath, $siteName, $sitePath, $outputPackageName)
{
	$cspackPath = "C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v$azureSdkVersion\bin\cspack.exe"
	$serviceDefinitionPath = "ServiceDefinition.csdef"

	$out = "/out:$outputPackageName"
	$role = "/role:$roleName;$rolePath"
	$rolePropertiesFile = "/rolePropertiesFile:$roleName;roleproperties.txt"
	$sites = "/sites:$roleName;$siteName;$sitePath"
	$sitePhysicalDirectories = "/sitePhysicalDirectories:$roleName;$siteName;$sitePath"

	Write-Host "create package"
	Write-Host $cspackPath $serviceDefinitionPath $out $role $rolePropertiesFile $sites $sitePhysicalDirectories
	& $cspackPath $serviceDefinitionPath $out $role $rolePropertiesFile $sites $sitePhysicalDirectories
}

Write-Host "unzip the cspkg file"
Unzip "$azureProjectName.ccproj.cspkg" $workingDirectory

Write-Host "unzip the cssx file"
$cssxFolder = "$workingDirectory\webrole"
Unzip (Get-Item (join-path -path $workingDirectory -childPath "$webProjectName*.cssx")) $cssxFolder

Write-Host "copy transformed web.config into approot"
$rolePath = "$cssxFolder\approot"
Copy-Item web.config .\$rolePath

Write-Host "copy transformed web.config into sitesroot\0"
$sitePath = "$cssxFolder\sitesroot\0"
Copy-Item web.config .\$sitePath

Generate-Package $azureSdkVersion $azureRoleName $rolePath $azureSiteName $sitePath $outputPackageName
