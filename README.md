octopus-azure-transforms
========================

This project demonstrates how to perform deploy-time transforms to an Azure CSPKG via Octopus. It contains three projects:

1. The web project ([OctopusVariableSubstitutionTester](https://github.com/davidpeden3/octopus-azure-transforms/tree/master/source/OctopusVariableSubstitutionTester)) that contains the web.config upon which transforms are applied.
2. The web role project ([Azure](https://github.com/davidpeden3/octopus-azure-transforms/tree/master/source/Azure)) that contains a web role that hosts the web project.
3. The deployment project ([Deployment](https://github.com/davidpeden3/octopus-azure-transforms/tree/master/source/Deployment)) that contains packaging and deployment related files.

The web project only contains a [web.config](https://github.com/davidpeden3/octopus-azure-transforms/blob/master/source/OctopusVariableSubstitutionTester/Web.config) and its related [web.release.config](https://github.com/davidpeden3/octopus-azure-transforms/blob/master/source/OctopusVariableSubstitutionTester/Web.Release.config). It is not a functional web site and its sole purpose is to create as lightweight of a project as possible to exercise the build, package, and deploy pipeline. This project does contain the MVC 5 NuGet packages but they are not used for anything. The web project does perform a build-time transform using the web.release.config file when built locally ([see the 'AfterBuild' target](https://github.com/davidpeden3/octopus-azure-transforms/blob/master/source/OctopusVariableSubstitutionTester/OctopusVariableSubstitutionTester.csproj#L143-L146) at the bottom of the .csproj file) but this is not necessary for deployment (as Octopus handles this for us when configured to do so) and is merely a local workstation convenience.

The build and deployment pipeline is performed by [TeamCity](http://www.jetbrains.com/teamcity/) using a combination of [MSBuild](http://msdn.microsoft.com/en-us/library/0k6kkbsd.aspx), [NuGet](https://www.nuget.org/), [Klondike](https://github.com/themotleyfool/Klondike), and [Octopus](http://octopusdeploy.com/). The build configuration looks like this:

![TeamCity Build Configuration](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/teamcity-build-configuration.png)

The Octopus process is configured like this:

![Octopus Process](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/octopus-process.png)

And includes the following variables:

![Octopus Variables](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/octopus-variables.png)

Note that deploy.ps1 and postdeploy.ps1 are used instead of predeploy.ps1 and deploy.ps1 because the Octopus transforms (variable substitution, web.release.config tranform, and app setting/connection string replacement) all occur *after* predeploy.ps1.

A successful build produces the following build log in TeamCity:

![TeamCity Build Log](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/teamcity-build-log.png)

and corresponding NuGet package:

![TeamCity NuGet Package](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/teamcity-nuget-package.png)

When the deployment is successful, the following files are written to disk:

![Octopus Pre- and Post-Processing](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/octopus-pre-and-post-processing.png)

The top folder is the dump of the NuGet package at the tentacle. The bottom folder is the result of running deploy.ps1 and postdeploy.ps1 at the configured deployment folder.

To accomplish the goal, the following key steps occur throughout the pipeline:

1. Use MSBuild to generate the initial CSPKG
2. Have Octopus transform the configuration files (web.config and ServiceConfiguration.Production.cscfg) at deployment time
3. Unzip the CSPKG
4. Replace the stock web.config with the transformed one
5. Repack the CSPKG
6. Clean up the temporary files

Deploy.ps1 produces the following CSPack command:

```
C:\Program Files\Microsoft SDKs\Windows Azure\.NET SDK\v2.3\bin\cspack.exe
  ServiceDefinition.csdef
	/out:OctopusVariableSubstitutionTester.1.0.0.82.cspkg
	/role:OctopusVariableSubstitutionTester;azurePackage\webrole\approot
	/rolePropertiesFile:OctopusVariableSubstitutionTester;roleproperties.txt
	/sites:OctopusVariableSubstitutionTester;Web;azurePackage\webrole\sitesroot\0
	/sitePhysicalDirectories:OctopusVariableSubstitutionTester;Web;azurePackage\webrole\sitesroot\0
```

The [roleproperties.txt](https://github.com/davidpeden3/octopus-azure-transforms/blob/master/source/Deployment/roleproperties.txt) file is used by ```CSPack.exe``` to produce RoleModel.xml inside the CSSX folder of the CSPKG. You can adjust these properties to whatever you want. I matched them to what was produced by MSBuild which, to my understanding, is inferred by the .csproj of the web project.

The result is a perfect replacement. When diffing the folder contents of the before and after CSPKG files, the only differences are the random GUIDs generated as a part of the packing process and the desired transformations to web.config.

![Araxis Folder Comparison](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/araxis-folder-comparison.png)

![web.config Comparison](https://raw.githubusercontent.com/davidpeden3/octopus-azure-transforms/master/documentation/web.config-comparison.png)
