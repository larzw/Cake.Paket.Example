# Example Cake Build Using Paket

This repository is a fork of the [minimal cake project](https://github.com/cake-build/example). Instead of using [NuGet](https://www.nuget.org/) for dependency management we use [paket](https://fsprojects.github.io/Paket/). Additionally, for convenience, we include an example build using mono on [Travis CI](https://travis-ci.org/).

## Build Status on Master Branch

|Build server|Platform|Build status|
|:--:|:--:|:--:|
|AppVeyor|Windows|[![Build status](https://ci.appveyor.com/api/projects/status/uipwpnm6vqn0lbte/branch/master?svg=true)](https://ci.appveyor.com/project/larzw/cake-paket-example-9djsj/branch/master)|
|Travis CI|Linux, OS X|[![Build Status](https://travis-ci.org/larzw/Cake.Paket.Example.svg?branch=master)](https://travis-ci.org/larzw/Cake.Paket.Example)

## Quick Start

- Clone the repository
- Run the appropriate build script
  - On Windows use PowerShell and run `.\build.ps1`. If it errors out due to an execution policy, take a look at [changing the execution policy](https://technet.microsoft.com/en-us/library/ee176961.aspx).
  - On Linux or OS X use the terminal and run `./build.sh`. You may need to change the permissions `chmod +x build.sh`.

**See [Cake.Paket](https://github.com/larzw/Cake.Paket) for more information.**

## Committing Binary Files

It's common practice not to commit binary files. However, this example commits paket.bootstrapper.exe as per pakets [getting started guild](https://fsprojects.github.io/Paket/getting-started.html). The paket team states

> "Commit .paket/paket.bootstrapper.exe into your repo and add .paket/paket.exe to your .gitignore file."

This is also what the F# foundation does for [ProjectScaffold](http://fsprojects.github.io/ProjectScaffold/), which is used to scaffold a prototypical .NET solution. 

However, pakets [FAQ](https://fsprojects.github.io/Paket/faq.html#What-files-should-I-commit) under the heading *"What files should I commit?"* lists paket.bootstrapper.exe as a file that can be committed, but does not have to be. So, if you would rather not commit it, you can modify the cake bootstrapper scripts so they download it.

My personal preference is to commit the bootstrapper because it's small and rarely changed. Furthermore, it makes collaborating easier. For example, if someone downloads your code they can run `.paket/paket.bootstrapper.exe` and then `.paket/paket.exe restore` to get all the dependencies. If the bootstrapper was not committed they would have to download it or run the build scripts.

## Questions

Feel free to open an [issue](https://github.com/larzw/Cake.Paket.Example/issues) or **@larzw** me via [Gitter](https://gitter.im/cake-contrib/Lobby)