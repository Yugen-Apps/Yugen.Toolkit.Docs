# Getting Started with DocFX, .Net Solution, Powershell and Github Pages

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

## Step3. Build our website

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
![1](/images/walkthroughs/docfx/1.png)

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
  |- articles
  |   |- gettingStarted.md
  |   |- toc.yml
  |- images
  |   |- logo.png
  |- ...
```

Congrats! Now if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs` and navigate to `http://localhost:8080/articles/gettingStarted.html`, you can now see a page similar to:
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
    topicHref: walkthroughs/index.md
```

So now our folder layout is:

```
  |- ...
  |- articles    
  |   |- walkthroughs
  |   |   |- docfx-github-actions.md
  |   |   |- index.md
  |   |   |- nuget-github-actions.md
  |   |   |- toc.yml
  |   |- gettingStarted.md
  |   |- toc.yml
  |- ...
```

Congrats! Now if you run command `.\docfx\docfx.exe docfx.json`, than `.\docfx\docfx.exe serve docs` and navigate to `http://localhost:8080/articles/walkthroughs/index.html`, you can now see a page similar to:
![3](/images/walkthroughs/docfx/3.png)

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
![4](/images/walkthroughs/docfx/4.png)

## Step6. Adding API Documentation to the Website

We built a website from a set of `.md` files. We call it `Conceptual Documentation`. Now we will learn to build a website from `.NET source code`, which is called `API Documentation`. We will also integrate `Conceptual Documentation` and `API Documentation` into one website so that we can navigate from `Conceptual` to `API`, or `API` to `Conceptual` seamlessly.

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
  |- api
  |    |- index.md
  |    |- toc.yml
  |- ...
```

## Step7. Generate Github Pages

To generate Github Pages, for the sake of semplicity,  we're goin to move the content of `docfx_project` to `C:\Dev\Yugen.Toolkit.Docs\`.
So now our `C:\Dev\Yugen.Toolkit.Docs\` folder layout is:

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


Run command `.\docfx\docfx.exe docfx_project/docfx.json`. Note that a new subfolder `docs` is generated under that folder. This is where the static website is generated.
The generated static website can be published to GitHub pages, You can also run command `.\docfx\docfx.exe serve docs` to preview the website locally.

## Step7. Add a C# project

By default `DocFX` use the `src` folder to generate documentation from the code, but we're going to use `C:\Dev\Yugen.Toolkit\`, to do this we need to edit the `docfx.json` file, and change the `src` parameter, we'll see it in the next step.

## Step8. Generate metadata for the C# project

So now our `docfx.json` file is:

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
```

We're going to generate `metadata` for `Yugen.Toolkit.Uwp.Controls` project, to do this we're going to change the follwing parameters:
1. Change `files` from `src/**.csproj` to `Yugen.Toolkit.Uwp.Controls/**.csproj`
2. Add to `exclude` the following folders `**/obj/**`, `**/bin/**`, `docs/**`
3. Add to `src` our solution folder `../Yugen.Toolkit`
4. Add to `properties` our `TargetFrameworks`: `netstandard2.0`
5. Change `dest` from `api` to `metadata/uwp.controls` (this is a personal preference)

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
  ```

Run `.\docfx\docfx.exe metadata`


we need to change from this:

```
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
```

to this

```
"content": [
{
  "files": [
    "metadata/toc.yml",
    "metadata/index.md",
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
```

than I like to change the following parameters from

```
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
  ```

  to

  ```
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
    "dest": "docs",
  ```
