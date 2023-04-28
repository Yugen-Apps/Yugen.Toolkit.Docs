# CI/CD UWP: Build, Sign with certificate, Release to App Center and Store with Azure Pipelines

1. [Creating a build pipeline](#1)
    1. [The configuration](#11)
    2. [The steps](#12)
    3. [Customizing the build](#13)
    4. [Setting the package version](#14)
        1. [Option 1. Date versioning](#141)
        2. [Option 2. Manual versioning](#142)
    5. [Apply Build number to manifest](#15)
        1. [Option 1. Date versioning](#151)
        2. [Option 2. Manual Versioning](#152)
2. [Create a release pipeline](#2)
    1. [Artifacts](#21)
    2. [Stages](#22)
    3. [Deploying the application](#23)
        1. [Option 1. Upload your package to Store](#231)
            1. [Step 1. Prerequisities](#2311)
            2. [Step 2. Obtaining your credentials](#2312)
            3. [Step 3. Create the service connection](#2313)
            4. [Step 4. Set up Release Pipeline Deploy](#2314)
        2. [Option 2. Other Options](#232)
            1. [Signing the package](#2321)
                1. [Step 1. Generate a certificate](#23211)
                2. [Step 2. Upload to secure files](#23212)
                3. [Step 3. Sign your UWP application](#23213)
                4. [Step 4. Download and copy .cer file](#23214)
                5. [Step 5. Zip your folder](#23215)
            2. [Upload your package to App Center](#2322)
                1. [Step 1. Create the service connection](#23221)
                2. [Step 2. Set up your app and distribution group](#23222)
                3. [Step3. Set up Release Pipeline Deploy](#23223)

## Creating a build pipeline {#1}

Build pipelines can be created under the `Pipelines > Pipelines` section of your project on Azure DevOps, and click on `New Pipeline`:

1. `Where is your code?` You can choose from among many options, like Azure Repos, GitHub, BitBucket, Other Git and Subversion. In this walkthrough we're going to use the new default `YAML` optionL, which is a markup language.
2. `Select a repository`Choose the repository
3. `Configure your pipeline` Azure Pipeline will propose a set of templates for different project types. Each of them will create a basic YAML file with some tasks already configured. In our scenario, the template to choose is `Universal Windows Platform`, which will compile our UWP or Windows Application Packaging Project and create an MSIX.
4. The template will create the following YAML file:

```yml
    # Universal Windows Platform
    # Build a Universal Windows Platform project using Visual Studio.
    # Add steps that test and distribute an app, save build artifacts, and more:
    # https://aka.ms/yaml

    trigger:
    - master

    pool:
      vmImage: 'windows-latest'

    variables:
      solution: '**/*.sln'
      buildPlatform: 'x86|x64|ARM'
      buildConfiguration: 'Release'
      appxPackageDir: '$(build.artifactStagingDirectory)\AppxPackages\\'

    steps:
    - task: NuGetToolInstaller@1

    - task: NuGetCommand@2
      inputs:
        restoreSolution: '$(solution)'

    - task: VSBuild@1
      inputs:
        platform: 'x86'
        solution: '$(solution)'
        configuration: '$(buildConfiguration)'
        msbuildArgs: '/p:AppxBundlePlatforms="$(buildPlatform)" 
                      /p:AppxPackageDir="$(appxPackageDir)" 
                      /p:AppxBundle=Always 
                      /p:UapAppxPackageBuildMode=StoreUpload'
```

### The configuration {#11}

The `trigger` section is used to enable continuous integration and specifies the criteria used to trigger a new build. By default, it contains the name of the branch we’re building `master`, which means that every commit to this branch will trigger a new build. In my implementation I'm going to change it to `release/*` so it will be triggered only on a commit in these branches,

```yml
    trigger:
    - release/*
```

The `pool` section contains the configuration of the agent that will execute the build. With `windows-latest` we specify that we want to use the latest Windows image.

The `variables` section defines a set of parameters that are leveraged during the build
process. Specifically:
- `solution` defines which solution we want to build. By default, the pipeline will build all the solutions included in the project.
- `buildPlatform` defines which architecture we want to support inside the package.
- `buildConfiguration` is the Visual Studio configuration used for the build.
- `appxPackageDir` is the folder where the package will be created if the build is
successful.

### The steps {#12}
The steps section contains the tasks that will be performed one after the other. Each task has a unique identifier and a set of properties to customize it. 
1. `NuGetToolInstaller` will download the most recent version of NuGet
2. `NuGetCommand` restore all the dependencies in the project. 
3. `VSBuild` will build the project and create an MSIX package.

### Customizing the build {#13}

1. Disable the package signing. By default, MSIX packages are signed with a self-signing certificate generated by Visual Studio during the build process. However, signing the package during the build process isn't a good practice because we would need to upload the certificate to the repository. This means every developer working on the project will have access to the certificate, increasing the risk of identity theft. As such, the recommended approach is to sign the package in the release pipeline and store the certificate in a safe way. We're going to see how to do this later in the chapter. For the moment, just disable the signing during the compilation by adding the `/p:AppxPackageSigningEnabled=false` parameter to the `msBuildArgs` property of the `VSBuild` task.

2. Upload the `artifacts`, you can think of the hosted agent as a sort of virtual machine. Every time a new build is triggered, a new instance is created, which takes care of executing all the tasks, one after the other, and then it's disposed of at the end. The consequence is that, if we don't store the output of the build somewhere, it will be lost as soon as the hosted agent is disposed of. Azure DevOps offers its own cloud storage for storing the artifacts. Artifacts are available to the developer for manual download and are important for building a release pipeline. In a CD pipeline, in fact, the deployment is typically kicked off when a new artifact is available as a consequence of a CI pipeline that has been successfully completed. To achieve this goal, you will need to add the following task as the last step.

```yml
    - task: PublishBuildArtifacts@1
    inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)\AppxPackages'
        ArtifactName: 'drop'
```

Now our pipeline YAML file should look like this:

```yml
    # Universal Windows Platform
    # Build a Universal Windows Platform project using Visual Studio.
    # Add steps that test and distribute an app, save build artifacts, and more:
    # https://aka.ms/yaml

    trigger:
    - release/*

    pool:
      vmImage: 'windows-latest'

    variables:
      solution: '**/*.sln'
      buildPlatform: 'x86|x64|ARM'
      buildConfiguration: 'Release'
      appxPackageDir: '$(build.artifactStagingDirectory)\AppxPackages\\'

    steps:   

    - task: NuGetToolInstaller@1

    - task: NuGetCommand@2
      inputs:
        restoreSolution: '$(solution)'

    - task: VSBuild@1
      inputs:
        platform: 'x86'
        solution: '$(solution)'
        configuration: '$(buildConfiguration)'
        msbuildArgs: '/p:AppxBundlePlatforms="$(buildPlatform)" 
                      /p:AppxPackageDir="$(appxPackageDir)" 
                      /p:AppxBundle=Always 
                      /p:UapAppxPackageBuildMode=StoreUpload 
                      /p:AppxPackageSigningEnabled=false'

    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)\AppxPackages'
        ArtifactName: 'drop'
```

Once you have finished editing the YAML file, you can click `Save and run`. The YAML file will be saved in the root of your repository, and the build will be triggered. You will be able to follow the build step by step, thanks to real-time logging. If the build is successful, you’ll be able to access the artifacts using the `Artifacts` button that will appear at the top of the build details page. From there, you will be able to explore and download the files that have been created.


Note: Since the YAML file is stored in the repository of your project, you can edit it on your local machine using an editor like Visual Studio or Visual Studio Code. The latter also offers an extension that adds IntelliSense support for the various tasks offered by Azure Pipeline.

### Setting the package version {#14}

#### Option 1. Date versioning {#141}

If you check the artifact, you will notice that the MSIX package has been generated using the version number that is declared in the manifest of your project. By default, however, the version number will not change for future builds, as the build environment is not persisted between them. It's our duty to manually update the manifest every time we push some code to the repository. However, this approach can lead to many problems. If we forget to update the number, and we generate an update with the same version number as the prevision one, we will break the update chain.

The solution is to leverage the build number generated by Azure DevOps to update the package version also, so that it will be automatically increased at every execution. However, there’s a catch. By default, Azure DevOps uses the following expression to generate a build number. 

```
    $(date:yyyyMMdd)$(rev:.r)
```

The dollar sign is used by Azure DevOps to reference variables, which can be configured on the portal. However, some of them are already built into Azure DevOps, like the one used for the date in the expression above. You can find the full list [here](https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml). The expression will generate a build number like the following.

```
    20190504.1
```

This build number, however, isn’t compatible with the version number required by MSIX packages, which must follow the convention `x.y.z.0`. We can change the build number by editing the YAML file and modifying the build configuration. To achieve this goal, go back to `Pipelines > Builds` in your Azure DevOps project, locate the build pipeline you previously created, and click `Edit`. You will get access to the advanced YAML editor. To define the new build number, you have to add a new entry before the steps section using the following snippet.

```
    name: $(date:yyyy).$(Month)$(rev:.r).0
```

With the `name` entry, we’re defining a new versioning for the build number. This time, we’re generating a version that is compatible with the MSIX requirements. 


#### Option 2. Manual versioning {#142}

1. Add the following variables 
```yml
    appxmanifest: '**/*.appxmanifest'
    versionNumber: 'Set dynamically below in a task'
```

2. Add the following snippet  `name: '$(Rev:r)'`
3. introduce the following powrshell script as first step

```yml
    - task: PowerShell@2
    inputs:
        targetType: 'inline'
        script: |
        [xml] $manifestXml = Get-Content '$(appxmanifest)'
        $version = [version]$manifestXml.Package.Identity.Version

        [string] $newVersion = "{0}.{1}.{2}.{3}" -f $version.Major, $version.Minor, $(Build.BuildNumber), 0
        Write-Host "Setting the release version number variable to '$newVersion'."
        Write-Host "##vso[task.setvariable variable=versionNumber]$newVersion"

        Write-Host "Setting the name of the build to '$newVersion'."
        Write-Host "##vso[build.updatebuildnumber]$newVersion"
```

this task take the current `major` and `minor` version from the current manifest and increment the `revision` according to the build number

3. Now our yaml file will look like this: 

### Apply Build number to manifest {#15}

The last step is to apply this build number to the manifest of our MSIX package. We can use a task created by a third-party developer. Save the YAML file you have updated, and then go back to the Azure DevOps dashboard. Locate the marketplace icon at the top and choose `Browse marketplace`. [link](https://marketplace.visualstudio.com/)

Search for an extension called `Manifest Versioning Build Task` by Richard Fennell, [link](https://marketplace.visualstudio.com/items?itemName=richardfennellBM.BM-VSTS-Versioning-Task), click it,
and then click `Get it free`. You will initialize the process to add the extension to your Azure
DevOps account. Once the extension has been installed, you can go back to the pipeline, click
`Edit`, and add the following step before the `VSBuild` step.

```yml
    - task: VersionAPPX@2
    displayName: 'Version MSIX'
```

This task doesn’t require any special parameter. It will simply edit the manifest of your project and apply the build number as the version.

Now our pipeline YAML file should look like this:

#### Option 1. Date versioning {#151}

```yml
    # Universal Windows Platform
    # Build a Universal Windows Platform project using Visual Studio.
    # Add steps that test and distribute an app, save build artifacts, and more:
    # https://aka.ms/yaml

    trigger:
    - release/*

    pool:
      vmImage: 'windows-latest'

    variables:
      solution: '**/*.sln'
      buildPlatform: 'x86|x64|ARM'
      buildConfiguration: 'Release'
      appxPackageDir: '$(build.artifactStagingDirectory)\AppxPackages\\'

    name: $(date:yyyy).$(Month)$(rev:.r).0

    steps:   

    - task: NuGetToolInstaller@1

    - task: NuGetCommand@2
      inputs:
        restoreSolution: '$(solution)'

    - task: VersionAPPX@2
      displayName: 'Version MSIX'

    - task: VSBuild@1
      inputs:
        platform: 'x86'
        solution: '$(solution)'
        configuration: '$(buildConfiguration)'
        msbuildArgs: '/p:AppxBundlePlatforms="$(buildPlatform)" 
                      /p:AppxPackageDir="$(appxPackageDir)" 
                      /p:AppxBundle=Always 
                      /p:UapAppxPackageBuildMode=StoreUpload 
                      /p:AppxPackageSigningEnabled=false'

    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)\AppxPackages'
        ArtifactName: 'drop'
```

#### Option 2. Manual Versioning {#152}

```yml
    # Universal Windows Platform
    # Build a Universal Windows Platform project using Visual Studio.
    # Add steps that test and distribute an app, save build artifacts, and more:
    # https://aka.ms/yaml

    trigger:
    - release/*

    pool:
      vmImage: 'windows-latest'

    variables:
      solution: '**/*.sln'
      buildPlatform: 'x86|x64|ARM'
      buildConfiguration: 'Release'
      appxPackageDir: '$(build.artifactStagingDirectory)\AppxPackages\\'
      appxmanifest: '**/*.appxmanifest'
      versionNumber: 'Set dynamically below in a task'

    name: '$(Rev:r)'

    steps:   

    - task: PowerShell@2
    inputs:
        targetType: 'inline'
        script: |
        [xml] $manifestXml = Get-Content '$(appxmanifest)'
        $version = [version]$manifestXml.Package.Identity.Version

        [string] $newVersion = "{0}.{1}.{2}.{3}" -f $version.Major, $version.Minor, $(Build.BuildNumber), 0
        Write-Host "Setting the release version number variable to '$newVersion'."
        Write-Host "##vso[task.setvariable variable=versionNumber]$newVersion"

        Write-Host "Setting the name of the build to '$newVersion'."
        Write-Host "##vso[build.updatebuildnumber]$newVersion"

    - task: NuGetToolInstaller@1

    - task: NuGetCommand@2
      inputs:
        restoreSolution: '$(solution)'

    - task: VersionAPPX@2
      displayName: 'Version MSIX'

    - task: VSBuild@1
      inputs:
        platform: 'x86'
        solution: '$(solution)'
        configuration: '$(buildConfiguration)'
        msbuildArgs: '/p:AppxBundlePlatforms="$(buildPlatform)" 
                      /p:AppxPackageDir="$(appxPackageDir)" 
                      /p:AppxBundle=Always 
                      /p:UapAppxPackageBuildMode=StoreUpload 
                      /p:AppxPackageSigningEnabled=false'

    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)\AppxPackages'
        ArtifactName: 'drop'
```

## Create a release pipeline {#2}

Now that you have a build pipeline that produces an MSIX package, you can define a release pipeline that will deploy it to your users. Release pipelines are created in the `Pipelines > Release` section of Azure DevOps. Building a release pipeline is a bit different than the steps we saw in the previous section.

1. Click on `new pipeline` (if you have alreadey other release pipelines, you'll need to click on `new > new release pipeline`)
2. `Selet a template` Clik on `empty job`

### Artifacts {#21}
1. In the first section, called `Artifacts`, you will have to specify which build output will be used for deployment. The default choice is to use the `build` artifacts, so you will have to select from the `source` list the build pipeline you previously created, in my case `emiliano84.yugen.mosaic.uwp`. I'll keep the resto to default values, `default version` to `Latest` and the `source aias` to `_emiliano84.Yugen.Mosaic.Uwp` and than click on `Add`
2. Once you have added it, you will notice a lightning symbol near the artifact’s name. If you want you can click it and enable the `Continuous deployment trigger`. It will turn the pipeline into a CD pipeline, which will trigger a new deployment every time a new build pipeline is successfully completed.

### Stages {#22}
In the second part of the template, you can create one or more stages, which are the various phases of the deployment. Each stage is typically mapped with a different environment: development, testing, production, etc. Each stage can run one or more tasks, which will take care of performing the actual deployment. In order to configure a stage, you just need to click the link below the stage name. You will get access to the visual task editor.

- click on `agent job` and in `agent pool` choose `azure pipelines`
- in `agent specification` choose `windows-2019`


### Deploying the application {#23}
The next step is to add a task to deploy the MSIX package, together with the App Installer file and the HTML page, in a location your users will be able to reach. Azure DevOps provide multiple tasks that can be used to achieve this goal:

#### Option 1. Upload your package to Store {#231}
`Browse marketplace`. [link](https://marketplace.visualstudio.com/) Search for an extension called `Windows Store` by Microsoft Fennell, [link](https://marketplace.visualstudio.com/items?itemName=MS-RDX-MRO.windows-store-publish&targetId=7bf16f40-3940-4da2-b0e0-c6fd1953f534), and install it.
Once you have installed this extension on your Azure DevOps account, you’ll be able to add to your release pipeline one of the two available tasks:
- `Windows Store – Publish` to publish the application as public.
- `Windows Store – Flight` to publish the application in a private flight ring.

##### Step 1. Prerequisities {#2311}

Prerequisites
1. You must have an Azure AD directory, and you must have global administrator permission for the directory. You can create a new Azure AD from [Partner Center](https://partner.microsoft.com/) > `Settings` > `Users` > `Tenants` > `Create new azure AD`

2. You must associate your Azure AD directory with your Dev Center account to obtain the credentials to allow this extension to access your account and perform actions on your behalf. `Partner Center` > `Settings` > `Users` > `Tenants` > `Associate Azure AD with your Partner Center account`
  - Login
  - Click on `confirm`
  - click on `users`
  - Click on `Sign in`
  - Login
  - click on `add azure ad applications`


3. The app you want to publish must already exist: this extension can only publish updates to existing applications. You can create your app in Partner Center.

4. You must have already created at least one submission for your app before you can use the Publish task provided by this extension. If you have not created a submission, the task will fail.

5. More information and extra prerequisites specific to the API can be found here.

##### Step 2. Obtaining your credentials {#2312}
Your credentials are comprised of three parts: the Azure Tenant ID, the Client ID and the Client secret. Follow these steps to obtain them:

1. In `Partner Center` > `Settings` > `Users` > `Tenants` > `Associate Azure AD with your Partner Center account` add the Azure AD application that represents the app or service that you will use to access submissions for your Dev Center account, and assign it the Manager role. If this application already exists in your Azure AD directory, you can select it on the Add Azure AD applications page to add it to your Dev Center account. Otherwise, you can create a new Azure AD application on the Add Azure AD applications page:
  - click `Add Azure AD applications`
  - click `New Azure AD application`
  - Fill the fields
  - Check as `Roles`: `Manager`
  - CLick `Save`

2. Return to the Manage users page, click the name of your Azure AD application to go to the application settings, and copy the Tenant ID and Client ID values.

3. Click Add new key. On the following screen, copy the `Key` value, which corresponds to the Client secret. You will not be able to access this info again after you leave this page, so make sure to not lose it. 

##### Step 3. Create the service connection {#2313}
To be able to publish your package in the store we need to authorize Azure DevOps to be able to connect to it. To do that: 
5. Go back to Azure DevOps 
6. Navigate to `Project Settings > Service connections` 
7. Click on `New service connection`
8. Choose `Windows Dev Center` and click `Next`
9. Paste the `Azure Tenant Id`, `client is` and `client secret` 
10. Give it a `Service connection name`
11. `Grant access permission to all pipelines` need to be chacked
11. Click `Save`

##### Step 4. Set up Release Pipeline Deploy {#2314}

Now you are ready to use the `Windows Store - Publish` and `Windows Store – Flight` tasks in your Azure DevOps Release Pipeline.

1. Go to your release pipleine
2. Click on `Tasks > Stage 1`
8. Click the + sign near the agent job to add a new task. 
9. Look for the task called `Windows Store - Publish` or `Windows Store – Flight` and `add` it.
10. Select the `Store service endpoint`
11. Paste your `application id`, you can find it in `partner center` > `your app` > `product management` > `product identity` > `store id`
12. Fill in `package file`: your package `**\*.msixupload`
13. If you want you can fill in the new `metadata` (if you want to update them as part of the process)
13. `Save`

However, there’s a catch. After you have selected the MSIX package, the output will look like the following.

`$(System.DefaultWorkingDirectory)/My build pipeline/drop/ContosoExpenses.Package_2019.5.23.0_Test/ContosoExpenses.Package_2019.5.23.0_x86.msixupload`

As you can see, the path contains the version number of the package, which will change at every build. As such, the release pipeline will complete successfully for the current build, but it will fail for the next ones. The solution is to use one of the global variables, `Build.BuildNumber`, which will be automatically replaced with the correct build number at every iteration.

`$(System.DefaultWorkingDirectory)/My build pipeline/drop/ContosoExpenses.Package_$(Build.BuildNumber)_Test/ContosoExpenses.Package_$(Build.BuildNumber)_x86.msixupload`

Thanks to this task, the updated MSIX package will be automatically submitted to certification at the end of the CI/CD process.

#### Option 2. Other Options {#232}

- You can use `AzureBlob File Copy` if you want to host your package on an `Azure Blob Storage`.
- You can use `Azure App Service Deploy` if you want to host your package on an `Azure web application`.
- You can use `FTP Upload` if you want to host your package on a website hosted by any web provider.
- For `App Center`keep reading

Going into the details in this book would be off topic, since there isn’t a unique solution, but it all depends on the requirements of your project. Additionally, all the tasks are easy to configure. For example, if you want to deploy your package using Azure Blob Storage, you will just have to link your Azure DevOps account with your Azure account and choose which one of your storage accounts will be the destination. Or if you want to deploy over FTP, you will have to provide the FTP URL, port, username, and password.

##### Signing the package {#2321}

As previously mentioned, it isn’t a good practice to sign the package in the build pipeline. The best place to perform this task is the release pipeline, since it allows us to store the certificate in a safe way, so that we don’t have to share it with other developers.

###### Step 1. Generate a certificate {#23211}

1. Open tha Package.appxmanifest as text and find this string: 
   `<Identity Name="Contoso.AssetTracker" Version="1.0.0.0"  Publisher="CN=Contoso Software, O=Contoso Corporation, C=US"/>`
2. Open powershell
3. Write the following command to generate a certificate: 
   `New-SelfSignedCertificate -Type Custom -Subject "{Publisher}" -KeyUsage DigitalSignature -FriendlyName "{Name}" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")`
   EG: 
   `New-SelfSignedCertificate -Type Custom -Subject "CN=Contoso Software, O=Contoso Corporation, C=US" -KeyUsage DigitalSignature -FriendlyName "Contoso.AssetTracker" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")`
4. It will create the `.cer` in `Personal\Intermediate certification authorities`
5. Copy the thumbrint output eg: `92BB2A9F1353EA0F701D73F6C35EC6C5FF3977A8`
6. Export a .pfx certificate 

  ```powershell
    $password = ConvertTo-SecureString -String {password} -Force -AsPlainText 
    Export-PfxCertificate -cert Cert:\CurrentUser\My\{thumbrint} -FilePath {filename}.pfx -Password $password
  ```
EG:
  ```powershell
    $password = ConvertTo-SecureString -String MyPassword -Force -AsPlainText 
    Export-PfxCertificate -cert Cert:\CurrentUser\My\92BB2A9F1353EA0F701D73F6C35EC6C5FF3977A8 -FilePath YugenCert.pfx -Password $password
  ```
6. Export a .cert certificate (this is needed if you want to include the cert in a build, EG for App Center)
  ```powershell
  $cert = Get-ChildItem -Path cert:\CurrentUser\My\{thumbrint}
  Export-Certificate -Cert $cert -FilePath c:\certs\{filename}.cer 
  ```
  EG:
  ```powershell
  $cert = Get-ChildItem -Path cert:\CurrentUser\My\92BB2A9F1353EA0F701D73F6C35EC6C5FF3977A8
  Export-Certificate -Cert $cert -FilePath YugenCert.cer 
  ```

- If you want to try the sign the bundle from powershell `&"C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64\signtool.exe" sign /fd SHA256 /a /f {filename}.pfx /p {password} {filename}.appxbundle`

###### Step 2. Upload to secure files {#23212}

1. Navigate to `Pipelines > Library > Secure files`
2. Click on `+ Secure file`
3. Upload `YugenCert.pfx`
4. Click `YugenCert.pfx`
5. Enable `Authorize for use in all pipelines`
2. Click on `+ Secure file`
3. Upload `YugenCert.cer`
4. Click `YugenCert.cer`
5. Enable `Authorize for use in all pipelines`

The files will be stored using the Secure File feature provided by Azure DevOps. Thanks to this feature, the file will be safely stored in the cloud without giving anyone the opportunity to download it. The only options are to leverage it in a pipeline or delete it.

###### Step 3. Sign your UWP application {#23213}

To achieve this goal, we need to leverage another extension from a third-party developer. Go back to the Marketplace, look for an extension called `Code Signing` by Stefan Kert, [link](https://marketplace.visualstudio.com/items?itemName=stefankert.codesigning) and install it to your Azure DevOps account. After that, go back to the release pipeline you’re building:
1. Click on `Tasks > Stage 1`
2. Click on `Agent job` and in `Agent Speciication` select `windows-2019`
3. Click the + sign near the agent job to add a new task. 
4. Look for the task called `Code Signing` and add it.
5. `Secure File` Provide the certificate, select the PFX certificate from the list. 
6. Define the password of the certificate. It isn’t a good idea to provide the password in
clear, so for the moment we just define a variable called `$(PfxPassword)`, which we’re
going to define later.
7. Specify the file to sign. Since our artifact will contain only an .msixbundle file, we can
just use a wild card `**/*.msixbundle` to specify this extension.
8. `Hashing algorithm` choose `SHA256`
8. `Select signtool.exe location` select `Latest version installed`
9. Click `Save`
10. Click on `Variables` section of the pipeline to define the password. 
11. Click `Add` and set as the name `PfxPassword` and, as the value, the real password. 
12. Click the `lock icon` displayed near the field to hide its value.

###### Step 4. Download and copy .cer file {#23214}

1. Go to your release pipleine
2. Click on `Tasks > Stage 1`
3. Click the + sign near the agent job to add a new task. 
4. Look for the task called `Download secure file` and `add` it.
5. In `Secure File` select `YugenCert.cer`
6. Click the + sign near the agent job to add a new task. 
7. Look for the task called `Copy Files` and `add` it.
8. Fill `Source Folder` with `$(Agent.TempDirectory)`
9. Fill `Contents` with `*.cer`
10. Fill `Target Folder` with `$(System.DefaultWorkingDirectory)/_emiliano84.Yugen.Mosaic.Uwp/drop/Yugen.Mosaic.Uwp_$(Build.BuildNumber)_Test`

###### Step 5. Zip your folder {#23215}

1. Go to your release pipleine
2. Click on `Tasks > Stage 1`
3. Click the + sign near the agent job to add a new task. 
4. Look for the task called `Archive files` and `add` it.
5. Fill `Root folder or file to archive`: `$(System.DefaultWorkingDirectory)/{MyBuildPipeline}/drop/{packagename}_{BuildNumber}_Test` EG: `$(System.DefaultWorkingDirectory)/_emiliano84.Yugen.Mosaic.Uwp/drop/Yugen.Mosaic.Uwp_$(Build.BuildNumber)_Test`
6. Uncheck `Prepend root folder name to archive paths`
7. Fill `Archive file to create`:`$(System.DefaultWorkingDirectory)/_emiliano84.Yugen.Mosaic.Uwp/drop.zip`

##### Upload your package to App Center {#2322}

Now we have our appxupload signed and ready to be sent to our users. My favorite tool for that is App Center, you can share your application with different groups of testers before publish it to a store and that’s really useful.

###### Step 1. Create the service connection {#23221}
To be able to publish your package in App Center we need to authorize Azure DevOps to be able to connect to it. To do that: 
1. Go to App Center 
2. Navigate to `Profile > Account Settings > API Tokens`
3. Click on `New API Token`, give it a name and be sure to choose `Full Access`. 
4. Copy the API token key, you will need it for the next step.

Warning: The token will never be visible after you close this view. Be sure to save it somewhere elese, otherwise you will need to recreate it.

5. Go back to Azure DevOps 
6. Navigate to `Project Settings > Service connections` 
7. Click on `New service connection`
8. Choose `Visual Studio App Center` and click `Next`
9. Paste the `API Token` 
10. Give it a `Service connection name`
11. `Grant access permission to all pipelines` need to be chacked
11. Click `Save`

##### Step 2. Set up your app and distribution group {#23222}

1. Go to App Center 
2. Create a new application project
3. Copy the `app slug` can be deducted by concatenating your username and application identifier separated by / for example the slug for:
  `https://appcenter.ms/users/emiliano84/apps/Yugen.Mosaic` 
  will be: 
  `emiliano84/Yugen.Mosaic`
3. The goal of App Center when you deploy your application is to distribute it to a distribution group. To create a new Distribution Group, navigate to `Distribute > Groups` from the navigation pane
4. Click on `Add Group` 
5. Provide a `group name` for the Distribution Group. 
6. If you want you can `Allow public access`
7. `add testers` to this group by email. (You can also add additional users after the group has been created.)
8. Copy the group ID, naviagete to `Distribute > Groups > yourgroupname` 
9. Go to the settings panel, click on the `settings icon` on the top right
10. You'll fine the Id below his name, Eg: `ID:aaaaa111-a11a-111a-1a1a-1a1111aa1a11`
11. If you want you can allow `App can be downloaded by anyone with link access`
12. Click `Done`

##### Step3. Set up Release Pipeline Deploy {#23223}

Now you are ready to use the `App Center Distribute` task in your Azure DevOps Release Pipeline.

1. Go to your release pipleine
2. Click on `Tasks > Stage 1`
8. Click the + sign near the agent job to add a new task. 
9. Look for the task called `App Center Distribute` and `add` it.
10. Select the `App Center service connection`
11. Paste your `app slug`
12. Fill your binary path `$(System.DefaultWorkingDirectory)/_emiliano84.Yugen.Mosaic.Uwp/drop.zip`
13. Fill in release notes
14. Paste your Destination IDs `aaaaa111-a11a-111a-1a1a-1a1111aa1a11`
15. Select `Symbols type`: `UWP`
16. Fill in `Symbols path`: `$(System.DefaultWorkingDirectory)/_emiliano84.Yugen.Mosaic.Uwp/drop/Yugen.Mosaic.Uwp_$(Build.BuildNumber)_Test/Yugen.Mosaic.Uwp_$(Build.BuildNumber)_x86.appxsym`

If you run the pipeline now you will see the application in your App Center account. You can now download it to in your Windows machine and test it!