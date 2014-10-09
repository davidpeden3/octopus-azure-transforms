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

#Unzips the cspkg file
Unzip "Azure.ccproj.cspkg" "azurePackage"

#Unzips the .cssx file that was contained in the cspkg file
Unzip (Get-Item (join-path -path "azurePackage" -childPath "OctopusVariableSubstitutionTester*.cssx")) "azurePackage\webrole"

#copy transformed web.config
Copy-Item web.config .\azurepackage\webrole\approot
Copy-Item web.config .\azurepackage\webrole\sitesroot\0