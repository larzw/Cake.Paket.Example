#tool paket:?package=NUnit.ConsoleRunner&group=main
#addin paket:?package=Cake.Figlet&group=build/setup

// You don't need to specify a group in the URI because you put it in the tools group
#tool paket:?package=JetBrains.ReSharper.CommandLineTools

// This is only needed if you want to use paket commands like PaketPack(...) and/or PaketPush(...)
// You don't need to specify a group in the URI because you put it in the addins group
#addin paket:?package=Cake.Paket

//////////////////////////////////////////////////////////////////////
// ARGUMENTS
//////////////////////////////////////////////////////////////////////

var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");

//////////////////////////////////////////////////////////////////////
// PREPARATION
//////////////////////////////////////////////////////////////////////

// Define directories.
var buildDir = Directory("./src/Example/bin") + Directory(configuration);
var reports = "./Reports";
var nuGet = "./NuGet";

//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////

Setup(context => 
{
    Information(Figlet("Cake.Paket.Example"));
});

Task("Clean")
    .Does(() =>
{
    CleanDirectories(new[] {buildDir, reports, nuGet});
});

Task("Build")
    .IsDependentOn("Clean")
    .Does(() =>
{
    if(IsRunningOnWindows())
    {
      // Use MSBuild
      MSBuild("./src/Example.sln", settings =>
        settings.SetConfiguration(configuration));
    }
    else
    {
      // Use XBuild
      XBuild("./src/Example.sln", settings =>
        settings.SetConfiguration(configuration));
    }
});

Task("Run-Unit-Tests")
    .IsDependentOn("Build")
    .Does(() =>
{
    NUnit3("./src/**/bin/" + configuration + "/*.Tests.dll", new NUnit3Settings {
        NoResults = true
        });
});

Task("Run-DupFinder")
    .IsDependentOn("Build")
    .Does(() =>
{
    if(IsRunningOnWindows())
    {
        EnsureDirectoryExists(reports);
        DupFinder("./src/Example.sln", new DupFinderSettings { ShowStats = true, ShowText = true, OutputFile = reports + "/dupFinder.xml" });
    }
});

// Uses the Cake.Paket addin to create a NuGet package
Task("Paket-Pack").IsDependentOn("Build").Does(() =>
{
    EnsureDirectoryExists(nuGet);
    PaketPack(nuGet, new PaketPackSettings { Version = "1.0.0" });
});

//////////////////////////////////////////////////////////////////////
// TASK TARGETS
//////////////////////////////////////////////////////////////////////

Task("Default")
    .IsDependentOn("Run-Unit-Tests").IsDependentOn("Run-DupFinder").IsDependentOn("Paket-Pack");

//////////////////////////////////////////////////////////////////////
// EXECUTION
//////////////////////////////////////////////////////////////////////

RunTarget(target);
