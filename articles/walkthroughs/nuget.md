# CI/CD Publish Nuget to GitHub Packages with GitHub Actions

## Before start
I went trough several issues to achieve this, so I decide to do twrite this, hopefully you'll fine it useful.

## Let's start
Assuming that you already have your repo on GitHub, with you VS solution and projects ready to be packagesd as nuget,
for example https://github.com/emiliano84/Toolkit
- https://github.com/emiliano84/Toolkit/tree/master/Yugen.Toolkit.Standard
- https://github.com/emiliano84/Toolkit/tree/master/Yugen.Toolkit.Uwp

### GitHub Actions Setup
Let's create a file in `.github/workflows/nuget.yml` this conatins all the workflow instructions, for example
- https://github.com/emiliano84/Toolkit/blob/master/.github/workflows/nugetStandard.yml for .net standard
- https://github.com/emiliano84/Toolkit/blob/master/.github/workflows/nugetUwp.yml for uwp class library

- Let’s define our action that will triggered when we push or merge to master branch

```YAML
name: Build, Pack and Publish Nuget
on:
  push:
    branches:    
      - master   
```

- Let's define our job and tell him which OS to use, we're going to use Windows of course

```YAML
jobs:   
  build_pack_publish:
    runs-on: windows-latest
    name: Build
```

- Let's write the steps

1.  Checkout the current Docs repo

```YAML
steps:
- uses: actions/checkout@v1   
```

2. Setup MSbuild, restore the nuget packages and build the solution in Release mode

```YAML
- name: Setup MSBuild.exe
  uses: warrenbuckley/Setup-MSBuild@v1

- name: MSBuild Restore
  run: msbuild Yugen.Toolkit.Standard\Yugen.Toolkit.Standard.csproj /p:Configuration="Release" /t:restore     

- name: MSBuild Build
  run: msbuild Yugen.Toolkit.Standard\Yugen.Toolkit.Standard.csproj /p:Configuration="Release"
```

3. Only for a .net standard project we can use this step to build the nuget package, all the nuget properties required will be set in the project file, details later

```YAML
- name: MSBuild Pack
  run: msbuild Yugen.Toolkit.Standard\Yugen.Toolkit.Standard.csproj /p:Configuration="Release" /t:pack 
```

4. Setup Nuget

```YAML
- name: Setup Nuget.exe
  uses: warrenbuckley/Setup-Nuget@v1
```

5. Only for a UWP project we need to use this step to build the nuget package, all the nuget properties require will be in the nuspec file, details later

```YAML
    - name: Nuget Pack
      run: nuget pack Yugen.Toolkit.Uwp\Yugen.Toolkit.Uwp.csproj -properties Configuration=Release
```
        
6. Setup our Nuget source and push the package
```YAML
- name: Nuget Add Source
  run: nuget source Add -Name "GitHub" -Source "https://nuget.pkg.github.com/emiliano84/index.json" -UserName emiliano84 -Password ${{ secrets.PERSONAL_TOKEN }}

- name: Nuget SetAPIKey
  run: nuget setApiKey ${{ secrets.PERSONAL_TOKEN }} -Source "GitHub"

- name: Nuget Push
  run: nuget push Yugen.Toolkit.Standard\bin\Release\*.nupkg -Source "GitHub"
```

I defined a USERNAME and PACKAGES_TOKEN secrets, for the token I generate one with the following permissions:  Repo, read:package, write:packages

### Nuget properties
- For the .net standard project, you need to update the project file with the following properties

```
<Version>1.0.6</Version>
<PackageProjectUrl>https://github.com/emiliano84/Toolkit</PackageProjectUrl>
<RepositoryUrl>https://github.com/emiliano84/Toolkit.git</RepositoryUrl>
```

for example
https://github.com/emiliano84/Toolkit/blob/master/Yugen.Toolkit.Standard/Yugen.Toolkit.Standard.csproj


- For the UWP project, you need to update the nuspec file with the following properties

```
<id>Yugen.Toolkit.Uwp</id>
<version>1.0.6</version>
<authors>emiliano84</authors>
<description>Yugen.Toolkit.Uwp</description>
<repository type="git" url="https://github.com/emiliano84/Toolkit.git" /> 
<projectUrl>https://github.com/emiliano84/Toolkit</projectUrl>
```

for exmple
https://github.com/emiliano84/Toolkit/blob/master/Yugen.Toolkit.Uwp/Yugen.Toolkit.Uwp.nuspec

That's all folks