# Getting Started with DocFX, Powershell and Github Pages

## Step1. Setup DocFX

1. Download docfx.zip from (https://github.com/dotnet/docfx/releases) 
2. Let's assume our visual studio solution is in `C:\Dev\Yugen.Toolkit\`
3. Create a new folder for the docs in 
`C:\Dev\Yugen.Toolkit.Docs\`
4. Unzip `docfx.zip` to `C:\Dev\Yugen.Toolkit.Docs\docfx\`
5. So now our folder layout is:

```
|- C:\Dev\
|   |- Yugen.Toolkit.Docs\
|   |- docfx\
|   |- Yugen.Toolkit\
```

## Step2. Init a DocFX project

1. Start powershell under `C:\Dev\Yugen.Toolkit.Docs\`
2. Call `.\docfx\docfx.exe init -q`. This command generates a `docfx_project` folder with the default `docfx.json` file under it. `docfx.json` is the configuration file `docfx` uses to generate documentation. `-q` option means generating the project quietly using default values, you can also try `.\docfx\docfx.exe init` and follow the instructions to provide your own settings.
6. So now our folder layout is:

```
|- C:\Dev\
|   |- Yugen.Toolkit.Docs\
|   |- docfx\
|   |- docfx_project\
|   |    |- api\
|   |    |- apidoc\
|   |    |- articles\
|   |    |- imges\
|   |    |- src\
|   |    |- docfx.json
|   |    |- toc.yml
|   |    |- index.yml
|   |- Yugen.Toolkit\
```

## Step3. Build our website
Run command `.\docfx\docfx.exe docfx_project/docfx.json`. Note that a new subfolder `_site` is generated under that folder. This is where the static website is generated.

## Step4. Preview our website
The generated static website can be published to GitHub pages, Azure websites, or your own hosting services without any further changes. You can also run command `.\docfx\docfx.exe serve docfx_project/_site` to preview the website locally.

If port `8080` is not in use, `docfx` will host `_site` under `http://localhost:8080`. If `8080` is in use, you can use `.\docfx\docfx.exe serve _site -p <port>` to change the port to be used by docfx.

Congrats! You can now see a simple website similar to:
![1](/images/walkthroughs/docfx/1.png)

## Step5. Add a set of articles to the website

1. Place more `.md` files into `articles`, e.g., `gettingStarted.md`. If the files reference any resources, put those resources into the `images` folder.

2. In order to organize these articles, we add these files into `toc.yml` under `articles` subfolder. The content of `toc.yml` is as below:

```
- name: Getting Started
  href: gettingStarted.md
```

So now our `docfx_project` folder layout is:

```
|- ...
|- articles
|   |- gettingStarted.md
|   |- toc.yml
|- images
|   |- details1_image.png
```
Congrats! You can now see a simple website similar to:
![2](/images/walkthroughs/docfx/2.png)

3. If you want, create a subdirectory into `articles`, e.g., `walkthroughs`, Place more `.md` files into `walkthroughs`, e.g., `docfx-github-actions.md`, `nuget-github-actions.md`.  In order to organize these articles, we add these files into `toc.yml` under `articles\walkthroughs` subfolder. The content of `toc.yml` is as below:

```
- name: CI/CD Publish DocFx to Github Pages with GitHub Actions
  href: docfx-github-actions.md
- name: CI/CD Publish Nuget to GitHub Packages with GitHub Actions
  href: nuget-github-actions.md
```

4. Update `articles\toc.yml` as below:

```
- name: Getting Started
  href: gettingStarted.md
- name: Walkthroughs
  href: walkthroughs/toc.yml
  topicHref: walkthroughs/howto.md
  ```

So now our `docfx_project` folder layout is:

```
|- ...
|- articles    
|   |- walkthroughs
|   |   |- docfx-github-actions.md
|   |   |- nuget-github-actions.md
|   |   |- toc.yml
|   |- gettingStarted.md
|   |- toc.yml
|- images
|    |- details1_image.png
```

![3](/images/walkthroughs/docfx/3.png)