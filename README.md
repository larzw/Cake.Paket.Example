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

## Paket

Using paket with cake is fairly simple as long as you

1. Don't forget to include cake in your paket.dependencies file.
2. Don't include tool aliases in your build.cake file. They go in your paket.dependencies file.
3. Don't include addin aliases in your build.cake file. Use reference aliases instead.
4. Don't use the bootstrapper scripts (`build.ps1` and/or `build.sh`) the cake team provides. Use the ones from this repository.

### Don't forget to include cake in your paket.dependencies file

I think this is pretty obvious, but easy to forget.

*paket.dependencies*
```
source https://nuget.org/api/v2

nuget Cake
```

### Don't include tool aliases in your build.cake file. They go in your paket.dependencies file

This is a natural step if you're familiar with paket. As an example, we'll start with a build.cake file that does **not** use paket.

*build.cake*
```csharp
#tool nuget:?package=NUnit.ConsoleRunner&version=3.4.0    

...

Task("Run-Unit-Tests").IsDependentOn("Build").Does(() =>
{
	NUnit3("./src/**/bin/" + configuration + "/*.Tests.dll", new NUnit3Settings { NoResults = true });
});
```
  
The thing at the top ``#tool nuget:?package=NUnit.ConsoleRunner&version=3.4.0`` is called an [alias](http://cakebuild.net/docs/fundamentals/aliases). It downloads the tool *NUnit.ConsoleRunner (version 3.4.0)* from NuGet so that NUnit can use it to run the unit tests. However, if we use paket we don't need to include the alias at the top. The alias just tells us what to include in our paket.dependencies file.
  
*paket.dependencies*
```
source https://nuget.org/api/v2

nuget Cake
nuget NUnit
nuget NUnit.ConsoleRunner = 3.4.0
```

*build.cake*
```csharp  
...

Task("Run-Unit-Tests").IsDependentOn("Build").Does(() =>
{
	NUnit3("./src/**/bin/" + configuration + "/*.Tests.dll", new NUnit3Settings { NoResults = true });
});
```

where we removed the alias from the *build.cake* script.

### Don't include addin aliases in your build.cake file. Use reference aliases instead

The addin alias downloads the addin from NuGet and adds a reference. Since we're using paket, we only need to add a reference. We'll continue with the build.cake file above that does **not** use paket and add the [Figlet](http://cakebuild.net/dsl/figlet) addin.

*build.cake*
```csharp
#tool nuget:?package=NUnit.ConsoleRunner&version=3.4.0
#addin "Cake.Figlet"

...

Setup(tool => 
{
    Information(Figlet("Cake.Paket.Example"));
});

...

Task("Run-Unit-Tests").IsDependentOn("Build").Does(() =>
{
	NUnit3("./src/**/bin/" + configuration + "/*.Tests.dll", new NUnit3Settings { NoResults = true });
});
```
  
If were using paket this becomes,
  
*paket.dependencies*
```
source https://nuget.org/api/v2

nuget Cake
nuget NUnit
nuget NUnit.ConsoleRunner = 3.4.0
nuget Cake.Figlet
```

*build.cake*
```csharp
#r "./packages/Cake.Figlet/lib/net45/Cake.Figlet.dll"

...

Setup(tool => 
{
    Information(Figlet("Cake.Paket.Example"));
});

...

Task("Run-Unit-Tests").IsDependentOn("Build").Does(() =>
{
	NUnit3("./src/**/bin/" + configuration + "/*.Tests.dll", new NUnit3Settings { NoResults = true });
});
```

where we replaced the addin alias with a reference alias in the *build.cake* script.

### Don't use the bootstrapper scripts (`build.ps1` and/or `build.sh`) the cake team provides. Use the ones from this repository

The cake team states [[Ref]](http://cakebuild.net/docs/tutorials/extending-the-bootstrapper), 

> "The Cake Bootstrapper that you can get directly from cakebuild.net is intended as a starting point for what can be done. It is the developer's discretion to extend the bootstrapper to solve for your own requirements."

The above quote provides peace of mind for extending the scripts. In fact, the scripts simply wrap `Cake.exe`. Essentially they,

1. Downloads nuget.exe (and possibly runs NuGet restore)
2. Uses nuget.exe to download Cake.exe 
3. Runs Cake.exe, for example `build.ps1 -Script MyBuildScript.cake -Target Default` is the same as `Cake.exe MyBuildScript.cake -Target Default`
	
For steps 1-2 the scripts in the repository use paket, while step 3 is the same. In addition to the command line arguments the old scripts allow, you can pass in the optional arguments: `-Cake`, `-Paket` (on PowerShell) or `--cake`, `--paket` (on bash). These arguments specify the relative paths to *Cake.exe* and  *.paket*. If you don't specify anything, the scripts look in *./packages/Cake/Cake.exe* and *./.paket*.

### Configuration Values
This section is for users who what a deeper understanding of how the modified bootstrapper scripts work.

If you look in the boostrapper scripts you'll see the environment variable *CAKE_PATHS_TOOLS*. This specifies the path to the tools directory so cake can locate the dependencies. There are a few alternatives to using environment variables

1. Specify the ToolPath in the build.cake file. As an example see [NUnit3Settings](http://cakebuild.net/api/cake.common.tools.nunit/7bd0c6da)
2. Use a cake.config file
3. Pass the path to Cake.exe

See the [default configuration values](http://cakebuild.net/docs/fundamentals/default-configuration-values) for more information on numbers 2-3.

## Committing Binary Files

It's common practice not to commit binary files. However, this example commits paket.bootstrapper.exe as per pakets [getting started guild](https://fsprojects.github.io/Paket/getting-started.html). The paket team states

> "Commit .paket/paket.bootstrapper.exe into your repo and add .paket/paket.exe to your .gitignore file."

This is also what the F# foundation does for [ProjectScaffold](http://fsprojects.github.io/ProjectScaffold/), which is used to scaffold a prototypical .NET solution. 

However, pakets [FAQ](https://fsprojects.github.io/Paket/faq.html#What-files-should-I-commit) under the heading *"What files should I commit?"* lists paket.bootstrapper.exe as a file that can be committed, but does not have to be. So, if you would rather not commit it, you can modify the cake bootstrapper scripts so they download it.

My personal preference is to commit the bootstrapper because it's small and rarely changed. Furthermore, it makes collaborating easier. For example, if someone downloads your code they can run `.paket/paket.bootstrapper.exe` and then `.paket/paket.exe restore` to get all the dependencies. If the bootstrapper was not committed they would have to download it or run the build scripts.
