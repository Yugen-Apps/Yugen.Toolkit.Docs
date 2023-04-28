# Yugen.Toolkit.Docs
![logo](/images/logo.png)

![DocFx Clone, Build And Push](https://github.com/emiliano84/Yugen.Toolkit.Docs/workflows/DocFx%20Clone,%20Build%20And%20Push/badge.svg)

## Getting Started
Please read the [getting started](https://emiliano84.github.io/Yugen.Toolkit.Docs/articles/gettingStarted.html) page for more detailed information about using the toolkit.

## Documentation
All documentation for the toolkit is hosted on [Github](https://emiliano84.github.io/Yugen.Toolkit.Docs/)
- [UWP Controls](https://emiliano84.github.io/Yugen.Toolkit.Docs/metadata/uwp.controls/index.html)

###  Sample App
Want to see the toolkit in action before jumping into the code?play with the [Sample App](https://github.com/emiliano84/Yugen.Toolkit)

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