# CI/CD Publish DocFx to Github Pages with GitHub Actions

## Before start

I went trough several tutorials online to achieve this, but everytime I found a different issue or something that can be improved, so I decide to do twrite this, if you're wondering about what about the issues I found, here there is a short list of them:
- I wanted to use two different repos, one for my project and one for the docs
- I wanted to publish the github pages website to gh-pages branch
- Use of older version of GitHub actions/workflow, now they switched to Yaml format
- Use of docker and linux. Why? we can achieve everything fast and easy using Windows, one more thing that slowdown the build s the rquirement to download and Install Mono
- Download docfx during the workflow, another slowdown, I'm simply going to include the docfx folder in the repo
- Last one, is a GitHub bug that deosn't trigger the GitHub pages build if you push the repo with your username and password, but you need to use a token

## Let's start
Assuming that you have already a full working DocFx build setup and you have a repo with your VS solution for example (https://github.com/emiliano84/Toolkit)

### Repository setup
To get started, Let's create a new repository for the docs for example (https://github.com/emiliano84/Toolkit.Docs) and let's add our docfx documenation solution, including the docfx folder that contains the docfx.exe

### GitHub Actions Setup
let's create a file in .github/workflows/docfx.yml this conatins all the workflow instructions
https://github.com/emiliano84/Toolkit.Docs/blob/master/.github/workflows/docfx.yml

- let's tell our job which OS to use
runs-on: windows-latest

- Let's write the steps
1-  Checkout the current Docs repo
    uses: actions/checkout@v1   

2- Clone our repository that contains our vs solution
    name: Clone
     run: git clone https://${{secrets.USERNAME}}:${{secrets.PACKAGES_TOKEN}}@github.com/emiliano84/Toolkit.git ../Toolkit
     shell: bash

3- Setup our git client
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

4- Fetch and checkout
     - name: git fetch origin
      run: git fetch origin
      shell: bash

    - name: git checkout master
      run: git checkout master
      shell: bash

5- Execute DocFX (for this I created a script that we'll see later)
     - name: Docfx
      id: docfx
      run: ".github/scripts/docfx.bat"
      shell: bash

6- My DocFx cofniguration, build the website in the docs folder, so I'm going to push this folder to the gh-pages branch

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

Thhat's it :)

### DocFx script

Lets' create the following file .github/scripts/docfx.bat (https://github.com/emiliano84/Toolkit.Docs/blob/master/.github/scripts/docfx.bat)

this file will exectue our docfx build

"docfx/docfx.exe" docfx.json --property VisualStudioVersion=16.0

it will run docfx.exe in the docfx folder, using the docfx.json and passing as property the version of visual studio we wanted to use... yes because I encountered one more problem, without passing this version, msbuild in docfx try to use the MSBuild\Microsoft\WindowsXaml\v16.2, but of course cannot be found so we tell msbuild to use MSBuild\Microsoft\WindowsXaml\v16.0

That's all folks



