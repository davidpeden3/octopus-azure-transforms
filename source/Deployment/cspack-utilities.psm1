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

function generatePackage($roleName, $roleBasePath, $siteName)
{
	$cspackPath = 'C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v2.3\bin\cspack.exe'
	$serviceDefinitionPath = "ServiceDefinition.csdef"
	$appPath = "$roleBasePath/approot"
	$sitePath = "$roleBasePath/sitesroot/0"

	$out = "/out:$roleName.cspkg"
	$role = "/role:$roleName;$appPath"
	$rolePropertiesFile = "/rolePropertiesFile:$roleName;roleproperties.txt"
	$sites = "/sites:$roleName;$siteName;$sitePath"
	$sitePhysicalDirectories = "/sitePhysicalDirectories:$roleName;Web;$sitePath"

	# Build CSPKG file
	Write-Host "create package"
	#& $cspackPath $serviceDefinitionPath $out $role $rolePropertiesFile $sites $sitePhysicalDirectories
	Write-Host $cspackPath $serviceDefinitionPath $out $role $rolePropertiesFile $sites $sitePhysicalDirectories
}