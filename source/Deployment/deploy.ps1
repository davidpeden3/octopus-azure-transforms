# $azureSdkVersion - the version of the Azure SDK
# $workingDirectory - the temp folder where the packing occurs
# $azureProjectName - the name of the azure project containing the role
# $webProjectName - the name of the web project used by the role
# $outputPackageName - the name of the final cspkg
# $azureRoleName - the name of the role
# $azureSiteName - the name of the site for the role

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

function generatePackage($azureSdkVersion, $roleName, $appPath, $sitePath, $siteName, $outputPackageName)
{
	$cspackPath = "C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v$azureSdkVersion\bin\cspack.exe"
	$serviceDefinitionPath = "ServiceDefinition.csdef"

	$out = "/out:$outputPackageName"
	$role = "/role:$roleName;$appPath"
	$rolePropertiesFile = "/rolePropertiesFile:$roleName;roleproperties.txt"
	$sites = "/sites:$roleName;$siteName;$sitePath"
	$sitePhysicalDirectories = "/sitePhysicalDirectories:$roleName;Web;$sitePath"

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
$appPath = "$cssxFolder\approot"
Copy-Item web.config .\$appPath

Write-Host "copy transformed web.config into sitesroot\0"
$sitePath = "$cssxFolder\sitesroot\0"
Copy-Item web.config .\$sitePath

generatePackage $azureSdkVersion $azureRoleName $appPath $sitePath $azureSiteName $outputPackageName
