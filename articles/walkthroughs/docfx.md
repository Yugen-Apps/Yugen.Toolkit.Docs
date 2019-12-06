# CI/CD Publish DocFx to Github Pages with GitHub Actions

## Why I Wrote this walkthrough
I went trough several tutorials online to achieve this, but everytime I found a different issue or something that can be improved, so I decide to do twrite this, if you're wondering about the different reasons why I decided to spent some of my time to write something I think useful: 
- I wanted to use two different repos instead of one, one for my project and one for the docs
- I wanted to publish the doc website to GitHub pages, in the gh-pages branch, not in another repo
- Some tutorial are based on the previous workflow file format, now they switched to YAML
- Some tutorial use Docker and Linux, but since Github actions host support Windows there is really no reason to use something else, this will only slow down our build that will require also the download and installation of Mono
- Some tutorial include the download DocFX in the workflow, I preferred to include the DocFx folder in the repo 
- Last but not least, I discovered a GitHub bug that doesn’t trigger the GitHub pages build if you push the repo with your username and password, but you need to use a token

## Let's start
For this walkthrough I’m Assuming that you have already a full working DocFx build setup and you have a repo with your VS solution for example (https://github.com/emiliano84/Toolkit)

### Repository setup
Let's create a new repository for the docs for example (https://github.com/emiliano84/Toolkit.Docs) and let's add our docfx documenation solution, including the docfx folder that contains the `docfx.exe`

### GitHub Actions Setup
Let's create a file in `.github/workflows/docfx.yml` this contains all the workflow instructions (https://github.com/emiliano84/Toolkit.Docs/blob/master/.github/workflows/docfx.yml)

- Let’s define our action that will triggered when we push or merge to master branch

```YAML
name: DocFx Clone, Build And Push
on:
  push:
    branches:    
      - master   
```

- Let's define our job and tell him which OS to use

```YAML
jobs:   
  clone_build_and_push:
    runs-on: windows-latest
    name: Clone, Build And Push
```

- Let's write the steps

1.  Checkout the current Docs repo

```YAML
steps:
- uses: actions/checkout@v1   
```

2. Clone our repository that contains our vs solution

```YAML
 - name: Clone
    run: git clone https://${{secrets.USERNAME}}:${{secrets.PACKAGES_TOKEN}}@github.com/emiliano84/Toolkit.git ../Toolkit
     shell: bash
```

I defined a USERNAME and PACKAGES_TOKEN secrets, for the token I generate one with the following permissions:  Repo, read:package, write:packages
Also I’m using Bash as shell instead of the default powershel

3. Configure our git client

```YAML
- name: Git Config email
  run: git config --global user.email "emiliano84@github.com"
  shell: bash

- name: Git Config name
  run: git config --global user.name "DocFx Bot"
  shell: bash

- name: Git Config remote.origin.url
  run: git config --global remote.origin.url "https://${{secrets.USERNAME}}:${{secrets.PACKAGES_TOKEN}}@github.com/emiliano84/Toolkit.Docs.git"
  shell: bash

- name: git remote add origin
  run: git remote add origin https://github.com/emiliano84/Toolkit.Docs
  continue-on-error: true
  shell: bash
```

4. Fetch and checkout

```YAML
- name: git fetch origin
  run: git fetch origin
  shell: bash

- name: git checkout master
  run: git checkout master
  shell: bash
```

5. Execute DocFX (for this I created a script that we'll see later)

```YAML
- name: Docfx
  id: docfx
  run: ".github/scripts/docfx.bat"
  shell: bash
```

6. Push the DocFX generated website to gh-pages branch

```YAML
- name: git subtree add
  run: git subtree add --prefix docs origin/gh-pages  
  continue-on-error: true
  shell: bash

- name: Git Add docs
  run: git add docs/* -f
  shell: bash

- name: Git Commit
  run: git commit -m "Docs"
  shell: bash

# create a local gh-pages branch containing the splitted output folder
- name: Git subtree
  run: git subtree split --prefix docs -b gh-pages 
  shell: bash

# force the push of the gh-pages branch to the remote gh-pages branch at origin
- name: Git Push
  run: git push -f https://${{secrets.USERNAME}}:${{secrets.PACKAGES_TOKEN}}@github.com/emiliano84/Toolkit.Docs.git gh-pages:gh-pages
  shell: bash    
```

Please note that I changed the default DocFx configuration, the website is generated in a folder called Docs

7. Lets' create the following script file `.github/scripts/docfx.bat`
(https://github.com/emiliano84/Toolkit.Docs/blob/master/.github/scripts/docfx.bat) 

this file will exectue our docfx build
`"docfx/docfx.exe" docfx.json --property VisualStudioVersion=16.0`

This will run docfx.exe in the docfx folder, using the docfx.json and passing as property the version of visual studio we want to use... yes because I encountered one more problem, without passing this version, msbuild in docfx try to use the `MSBuild\Microsoft\WindowsXaml\v16.2`, but it doesn’t exist, so we need to tell msbuild to use `MSBuild\Microsoft\WindowsXaml\v16.0`

8. Let’s set our GitHub Pages
Repository -> Settings -> GitHub Pages -> Source -> gh-pages branch

That's all folks
