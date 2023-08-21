# Yugen.Toolkit.Docs
![logo](/docfx_project/images/logo.png)

[![DocFx Clone, Build And Push](https://github.com/Yugen-Apps/Yugen.Toolkit.Docs/actions/workflows/docfx.yml/badge.svg)](https://github.com/Yugen-Apps/Yugen.Toolkit.Docs/actions/workflows/docfx.yml)

## Getting Started
Please read the [getting started](https://yugen-apps.github.io/Yugen.Toolkit.Docs/articles/gettingStarted.html) page for more detailed information about using the toolkit.

## Documentation
All documentation for the toolkit is hosted on [GitHub Pages](https://yugen-apps.github.io/Yugen.Toolkit.Docs/)
- [UWP Controls](https://yugen-apps.github.io/Yugen.Toolkit.Docs/metadata/uwp.controls/index.html)

###  Sample App
Want to see the toolkit in action before jumping into the code?play with the [Sample App](https://github.com/Yugen-Apps/Yugen.Toolkit)

### DocFX 2.6 CheatSheet

dotnet tool update -g docfx  
docfx init --quiet  

docfx docfx_project/docfx.json  
docfx docfx_project/docfx.json --serve  

docfx metadata docfx_project/docfx.json  
docfx metadata docfx_project/docfx.json --property VisualStudioVersion=17.0  
docfx build docfx_project/docfx.json  
docfx serve docfx_project/_site  


"TargetFramework": "win10"  
"TargetFramework": "uap10.0"  
"TargetFramework": "uap"  
"TargetFramework": "netcore50"  
"TargetFramework": "netstandard2.0"  


stride-docs-next  