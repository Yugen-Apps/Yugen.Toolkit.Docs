# Getting Started with DocFX, .Net Solution, Powershell and Github Pages

This tutorial is based on how I generate this Github Pages website, in (https://github.com/emiliano84/Yugen.Toolkit.Docs) and generate documentation for (https://github.com/emiliano84/Yugen.Toolkit) projects

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
  |   |    |- docfx\
  |   |- Yugen.Toolkit\
```

## Step2. Init a DocFX project

1. Start powershell under `C:\Dev\Yugen.Toolkit.Docs\`
2. Call `.\docfx\docfx.exe init -q -o ./`. 
    - `init` helps generates a default project. 
    - `docfx.json` is the configuration file `docfx` uses to generate documentation. 
    - `-q` option means generating the project quietly using default values, you can also try `.\docfx\docfx.exe init` and follow the instructions to provide your own settings.
    - `-o ./` option means generating the project in the current folder.
3. So now our folder layout is:

```
  |- C:\Dev\
  |   |- Yugen.Toolkit.Docs\
  |   |    |- docfx\
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

## Step3. Build our website (GitHub Psges ready)

So now our `docfx.json` file is:

```
  ...
  "overwrite": [
      {
        "files": [
          "apidoc/**.md"
        ],
        "exclude": [
          "obj/**",
          "_site/**"
        ]
      }
    ],
  "dest": "_site",
  ...
```

We're going to change te `dest` parameter fron `_site` to `docs`, this is where the static website is generated, in this way can be easily deployed to Github Pages

```
  ...
  "overwrite": [
  {
    "files": [
      "apidoc/**.md"
    ],
    "exclude": [
      "obj/**",
      "docs/**"
    ]
  }
  ],
  "dest": "docs",
  ...
```

Run command `.\docfx\docfx.exe docfx.json`, a new subfolder `docs` is generated. 

The generated static website can be published to GitHub pages, Azure websites, or your own hosting services without any further changes. 

## Step4. Preview our website
You can also run command `.\docfx\docfx.exe serve docs` to preview the website locally.

If port `8080` is not in use, `docfx` will host `docs` under `http://localhost:8080`. If `8080` is in use, you can use `.\docfx\docfx.exe serve docs -p <port>` to change the port to be used by docfx.

Congrats! You can now see a simple website similar to:
![1](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/1.png)

## Step5. Add a set of articles to the website

1. Place more `.md` files into `articles`, e.g., `gettingStarted.md`. If the files reference any resources, put those resources into the `images` folder.

2. In order to organize these articles, we add these files into `toc.yml` under `articles` subfolder. The content of `toc.yml` is as below:

```
  - name: Getting Started
    href: gettingStarted.md
```

So now our folder layout is:

```
  |- ...
  |- articles\
  |   |- gettingStarted.md
  |   |- toc.yml
  |- images\
  |   |- logo.png
  |- ...
```

Congrats! Now if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs` and navigate to `http://localhost:8080/articles/gettingStarted.html`, you can now see a page similar to:
![2](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/2.png)

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
    topicHref: walkthroughs/index.md
```

So now our folder layout is:

```
  |- ...
  |- articles\ 
  |   |- walkthroughs\
  |   |   |- docfx-github-actions.md
  |   |   |- index.md
  |   |   |- nuget-github-actions.md
  |   |   |- toc.yml
  |   |- gettingStarted.md
  |   |- toc.yml
  |- ...
```

Congrats! Now if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs` and navigate to `http://localhost:8080/articles/walkthroughs/index.html`, you can now see a page similar to:
![3](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/3.png)

### Template

If you would like to change template, you can create your own or go to `https://dotnet.github.io/docfx/templates-and-plugins/templates-dashboard.html` and download the one that you like, I choosed `darkFX`.
1. Download the theme
2. Create a `templates` folder 
3. Copy the extracted `darkfx` folder
4. So now our folder layout is:

```
  |- C:\Dev\
  |   |- Yugen.Toolkit.Docs\
  |   |    |- templates\
  |   |    |    |- darkfx\
  |- ...
```

And our `docfx.json` file is:

```
  ...
    "template": [
        "default"
      ],
  ...
```

5. Let's add our `darkfx` to `template` parameter

```
  ...
  "template": [
    "default",
    "templates/darkfx"
  ],
  ...
```

Congrats! Now if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs`, you can now see a page similar to:
![4](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/4.png)

#### Customize a template

1. Export template: Run `.\docfx\docfx.exe template export default`, then you'll see default template in `_exported_templates\default`
2. Edit the files you want to customizem eg:
  - HTML changes: modify `_exported_templates\default\partials\footer.tmpl.partial` and copy the modified file to `templates\darkfx\partials\footer.tmpl.partial`
  - CSS changes: modify `_exported_templates\default\styles\docfx.css` or `_exported_templates\default\styles\main.css` and copy the modified file to `templates\darkfx\styles\main.css`

## Step6. Adding API Documentation to the Website

We built a website from a set of `.md` files. We call it `Conceptual Documentation`. Now we will learn to build a website from `.NET source code`, which is called `API Documentation`. We will also integrate `Conceptual Documentation` and `API Documentation` into one website so that we can navigate from `Conceptual` to `API`, or `API` to `Conceptual` seamlessly.

So now our folder layout is:

```
  |- ...
  |- articles\
  |   |- walkthroughs\
  |   |   |- docfx-github-actions.md
  |   |   |- nuget-github-actions.md
  |   |   |- toc.yml
  |   |- gettingStarted.md
  |   |- toc.yml
  |- images\
  |    |- details1_image.png
  |- api\
  |    |- .gitignore
  |    |- index.md
  |    |- toc.yml
  |- ...
```

And our `docfx.json` file is:

```
  "metadata": [
    {
      "src": [
        {
          "files": [
            "src/**.csproj"
          ]
        }
      ],
      "dest": "api",
      "disableGitFeatures": false,
      "disableDefaultFilter": false
    }
  ],
  ...
```

1. Add a C# project

By default `DocFX` use the `src` folder to generate documentation from the code, but we're going to use `C:\Dev\Yugen.Toolkit\`, to do this we need to make some changes in the `docfx.json` file. In this example we're going to generate `metadata` for `Yugen.Toolkit.Uwp.Controls` project, to do this we're going to change the follwing parameters:
1. Change `files` from `src/**.csproj` to `Yugen.Toolkit.Uwp.Controls/**.csproj`
2. Add to `exclude` the following folders `**/obj/**`, `**/bin/**`, `docs/**`
3. Add a `src` parameter to `src` with our solution folder `../Yugen.Toolkit`.
4. Add to `properties` our `TargetFrameworks`: `netstandard2.0`
5. Change `dest` from `api` to `metadata/uwp.controls` (this is a personal preference)
6. So now our `docfx.json` file is:

```
  "metadata": [
    {
      "src": [
        {
          "files": [
            "Yugen.Toolkit.Uwp.Controls/**.csproj"
          ],
          "exclude": [
            "**/obj/**",
            "**/bin/**",
            "docs/**"
          ],
          "src": "../Yugen.Toolkit"
        }
      ],
      "properties": {
        "TargetFrameworks": "netstandard2.0"
      },
      "dest": "metadata/uwp.controls",
      "disableGitFeatures": false,
      "disableDefaultFilter": false
    }
  ],
  ...
```

### If you followed step 5, and like me prefer to generate project metadata to a spcific folder
1. rename our `api` folder to `metadata`.
2. Create a `uwp.controls` folder in `metadata`
3. Move `index.md` and `toc.yml` to `uwp.controls`
4. So now our folder layout is:

```
  |- ...
  |- articles\ 
  |   |- walkthroughs\
  |   |   |- docfx-github-actions.md
  |   |   |- nuget-github-actions.md
  |   |   |- toc.yml
  |   |- gettingStarted.md
  |   |- toc.yml
  |- images\
  |    |- details1_image.png
  |- metadata\
  |    |- .gitignore
  |    |- uwp.controls\
  |    |    |- index.md
  |    |    |- toc.yml
  |- ...
```

3. We need to change the our `docfx.json` that now looks like this:

```
  ...
 "content": [
    {
      "files": [
        "api/**.yml",
        "api/index.md"
      ]
    },
    {
      "files": [
        "articles/**.md",
        "articles/**/toc.yml",
        "toc.yml",
        "*.md"
      ]
    }
  ],
  ...
```

to this

```
  ...
  "content": [
  {
    "files": [
      "metadata/uwp.controls/*.yml",
      "metadata/uwp.controls/index.md"
    ]
  },
  {
    "files": [
      "articles/**.md",
      "articles/**/toc.yml",
      "toc.yml",
      "*.md"
    ]
  }
  ],
  ...
```

4. Now we need to fix the top nvaigation menu, change `C:\Dev\Yugen.Toolkit.Docs\toc.yml` from this 

```
  - name: Articles
    href: articles/
  - name: Api Documentation
    href: api/
    homepage: api/index.md
```

to this

```
  - name: Articles
    href: articles/
  - name: Uwp.Controls
    href: metadata/uwp.controls/
    homepage: metadata/uwp.controls/index.md
```

## Step7. Generate metadata for the C# project, 
Run `.\docfx\docfx.exe metadata`

Congrats! Now if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs`, you can now see a page similar to:
![5](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/5.png)


## Step8. Overwrite Files
DocFX introduces the concept of `Overwrite File` to modify or add properties to `Models` without changing the input `Conceptual Files` and `Metadata Files`.

`Overwrite Files` are Markdown files with multiple `Overwrite Sections` starting with YAML header block. A valid YAML header for an `Overwrite Section MUST` take the form of valid YAML set between triple-dashed lines and start with property uid. 

For the sake of clarity I rename the `apidoc` folder to `ovewrite` and create a `uwp.controls` folder inside. Here is a basic example of an Overwrite file `C:\Dev\Yugen.Toolkit.Docs\overwrite\uwp.controls\Yugen.Toolkit.Uwp.Controls.Collections.md`:

```
---
uid: Yugen.Toolkit.Uwp.Controls.Collections
---

This is overwritten content: Code Snippet

[!code-csharp[EdgeTappedListViewEventArgs](../../../Yugen.Toolkit/Yugen.Toolkit.Uwp.Controls/Collections/EdgeTappedListViewEventArgs.cs)]
```

this files is going to include a code snippet `EdgeTappedListViewEventArgs.cs` in the `Yugen.Toolkit.Uwp.Controls.Collections` page
So now our folder layout is:

```
  |- ...
  |- ovewrite\
  |    |- uwp.controls\
  |    |    |- Yugen.Toolkit.Uwp.Controls.Collections.md
  |- ...
```

`uid` for an `Overwrite Model` stands for the Unique IDentifier of the Model it will overwrite. So it is allowed to have multiple `Overwrite Sections` with YAML Header containing the same `uid`. For one `Overwrite File`, the latter `Overwrite Section` overwrites the former one with the same `uid`. For different `Overwrite Files`, the order of overwrite is Undetermined. So it is suggested to have `Overwrite Sections` with the same `uid` in the same `Overwrite File`.

### Apply Overwrite Files
Inside `docfx.json`, `overwrite` is used to specify the `Overwrite Files`. We need to change the our `docfx.json` that now looks like this:

```
...
  "overwrite": [
      {
        "files": [
          "apidoc/**.md"
        ],
        "exclude": [
          "obj/**",
          "_site/**"
        ]
      }
    ]
...
```

to this

```
...
    "overwrite": [
    {
      "files": [
        "overwrite/**.md"
      ],
      "exclude": [
        "obj/**",
        "docs/**"
      ]
    }
  ],
...
```

Now the page `http://localhost:8080/metadata/uwp.controls/Yugen.Toolkit.Uwp.Controls.Collections.html` looks like this:
![6](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/6.png)

But if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs`, you can now see a page similar to:
![7](/Yugen.Toolkit.Docs/images/walkthroughs/docfx/7.png)

That's all folks!

For further details refer to (https://dotnet.github.io/docfx/index.html)
Don't forget to check the rest of walktroughs for CI/CD implementation