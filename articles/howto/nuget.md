# CI/CD Publish Nuget to GitHub Package Registry (Beta) with GitHub Actions

## Before start

This feature it's still in beta and I already went trough a breaking change

## Let's start
Assuming that you already have your repo on GitHub, with you VS solution and projects ready to be packagesd as nuget,
for example https://github.com/emiliano84/Toolkit
- https://github.com/emiliano84/Toolkit/tree/master/Yugen.Toolkit.Standard
- https://github.com/emiliano84/Toolkit/tree/master/Yugen.Toolkit.Uwp

### GitHub Actions Setup
let's create a file in .github/workflows/nuget.yml this conatins all the workflow instructions, for example
- https://github.com/emiliano84/Toolkit/blob/master/.github/workflows/nugetStandard.yml for .net standard
- https://github.com/emiliano84/Toolkit/blob/master/.github/workflows/nugetUwp.yml for uwp class library

- let's tell our job which OS to use
runs-on: windows-latest

- Let's write the steps
1-  Checkout the current Docs repo
    - uses: actions/checkout@v1   
    
2-  Setup MSbuild, restore the nuget packages and build the solution in Release mode
    - name: Setup MSBuild.exe
      uses: warrenbuckley/Setup-MSBuild@v1

    - name: MSBuild Restore
      run: msbuild Yugen.Toolkit.Standard\Yugen.Toolkit.Standard.csproj /p:Configuration="Release" /t:restore     

    - name: MSBuild Build
      run: msbuild Yugen.Toolkit.Standard\Yugen.Toolkit.Standard.csproj /p:Configuration="Release"
3- For a .net standard project we can use this step to build the nuget package, all the nuget properties are in project file
    - name: MSBuild Pack
      run: msbuild Yugen.Toolkit.Standard\Yugen.Toolkit.Standard.csproj /p:Configuration="Release" /t:pack 

4- Setup Nuget
    - name: Setup Nuget.exe
      uses: warrenbuckley/Setup-Nuget@v1

5- For a UWP project we can have to use this step to build the nuget package, all the nuget properties are in the nuspec file
    - name: Nuget Pack
      run: nuget pack Yugen.Toolkit.Uwp\Yugen.Toolkit.Uwp.csproj -properties Configuration=Release
        
 6- Setup our Nuget source and push the package
    - name: Nuget Add Source
      run: nuget source Add -Name "GitHub" -Source "https://nuget.pkg.github.com/emiliano84/index.json" -UserName emiliano84 -Password ${{ secrets.PERSONAL_TOKEN }}

    - name: Nuget SetAPIKey
      run: nuget setApiKey ${{ secrets.PERSONAL_TOKEN }} -Source "GitHub"

    - name: Nuget Push
      run: nuget push Yugen.Toolkit.Standard\bin\Release\*.nupkg -Source "GitHub"

### Nuget properties
For the .net standard project, you need to update the project file with the following properties, 
<Version>1.0.6</Version>
    <PackageProjectUrl>https://github.com/emiliano84/Toolkit</PackageProjectUrl>
    <RepositoryUrl>https://github.com/emiliano84/Toolkit.git</RepositoryUrl>
for exmple
https://github.com/emiliano84/Toolkit/blob/master/Yugen.Toolkit.Standard/Yugen.Toolkit.Standard.csproj


For the .uwp project, you need to update the nuspec file with the following properties, 
   <id>Yugen.Toolkit.Uwp</id>
    <version>1.0.6</version>
    <authors>emiliano84</authors>
    <description>Yugen.Toolkit.Uwp</description>
    <repository type="git" url="https://github.com/emiliano84/Toolkit.git" /> 
    <projectUrl>https://github.com/emiliano84/Toolkit</projectUrl>
for exmple
https://github.com/emiliano84/Toolkit/blob/master/Yugen.Toolkit.Uwp/Yugen.Toolkit.Uwp.nuspec
