##########################################################################
# This is the Cake bootstrapper script for PowerShell.
# This file was originally downloaded from https://github.com/cake-build/resources
# This version was download from https://github.com/larzw/Cake.Paket.Example
# It was modified to use paket (instead of NuGet) for dependency management.
# Feel free to change this file to fit your needs.
##########################################################################

<#

.SYNOPSIS
This is a Powershell script to bootstrap a Cake build.

.DESCRIPTION
This Powershell script will download paket.exe if missing, 
install all your dependencies (including Cake) via paket.exe restore
and execute your Cake build script with the parameters you provide.

.PARAMETER Script
The build script to execute.
.PARAMETER Paket
The relative path to the .paket directory.
.PARAMETER Cake
The relative path to Cake.exe.
.PARAMETER Target
The build script target to run.
.PARAMETER Configuration
The build configuration to use.
.PARAMETER Verbosity
Specifies the amount of information to be displayed.
.PARAMETER Experimental
Tells Cake to use the latest Roslyn release.
.PARAMETER WhatIf
Performs a dry run of the build script.
No tasks will be executed.
.PARAMETER Mono
Tells Cake to use the Mono scripting engine.
.PARAMETER ScriptArgs
Remaining arguments are added here.
.LINK
http://cakebuild.net

#>

[CmdletBinding()]
Param(
    [string]$Script = "build.cake",
    [ValidatePattern('.paket$')]
    [string]$Paket = ".\.paket",
    [ValidatePattern('Cake.exe$')]
    [string]$Cake = ".\packages\Cake\Cake.exe",
    [string]$Target = "Default",
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",
    [ValidateSet("Quiet", "Minimal", "Normal", "Verbose", "Diagnostic")]
    [string]$Verbosity = "Verbose",
    [switch]$Experimental,
    [Alias("DryRun","Noop")]
    [switch]$WhatIf,
    [switch]$Mono,
    [Parameter(Position=0,Mandatory=$false,ValueFromRemainingArguments=$true)]
    [string[]]$ScriptArgs
)

Write-Host "Preparing to run build script..."

# Should we use mono?
$UseMono = "";
if($Mono.IsPresent) {
    Write-Verbose -Message "Using the Mono based scripting engine."
    $UseMono = "-mono"
}

# Should we use the new Roslyn?
$UseExperimental = "";
if($Experimental.IsPresent -and !($Mono.IsPresent)) {
    Write-Verbose -Message "Using experimental version of Roslyn."
    $UseExperimental = "-experimental"
}

# Is this a dry run?
$UseDryRun = "";
if($WhatIf.IsPresent) {
    $UseDryRun = "-dryrun"
}

Write-Verbose -Message "Using paket for dependency management..."

# Make sure the .paket directory exits
$PaketFullPath = Resolve-Path $Paket
if(!(Test-Path $PaketFullPath)) {
    Throw "Could not find .paket directory at $PaketFullPath"
}
Write-Verbose -Message "Found .paket in PATH at $PaketFullPath"

# Set the path to the dependencies
$PaketRoot = Split-Path (Resolve-Path $Paket) -Parent
$TOOLS_DIR = Join-Path $PaketRoot "packages"
Write-Verbose -Message "Set the packages dependency directory PATH to $TOOLS_DIR"
$ENV:CAKE_PATHS_TOOLS = $TOOLS_DIR
Write-Verbose -Message "Set CAKE_PATHS_TOOLS environment variable to $ENV:CAKE_PATHS_TOOLS"

# If paket.exe does not exits then download it using paket.bootstrapper.exe
$PAKET_EXE = Join-Path $PaketFullPath "paket.exe"
if (!(Test-Path $PAKET_EXE)) {   
    # If paket.bootstrapper.exe exits then run it.
    $PAKET_BOOTSTRAPPER_EXE = Join-Path $PaketFullPath "paket.bootstrapper.exe"
    if (!(Test-Path $PAKET_BOOTSTRAPPER_EXE)) {
        Throw "Could not find paket.bootstrapper.exe at $PAKET_BOOTSTRAPPER_EXE"
    }
    Write-Verbose -Message "Found paket.bootstrapper.exe in PATH at $PAKET_BOOTSTRAPPER_EXE"

    # Download paket.exe
    Write-Verbose -Message "Running paket.bootstrapper.exe to download paket.exe"
    Invoke-Expression $PAKET_BOOTSTRAPPER_EXE
        
    if (!(Test-Path $PAKET_EXE)) {
        Throw "Could not find paket.exe at $PAKET_EXE"
    }
}
Write-Verbose -Message "Found paket.exe in PATH at $PAKET_EXE"

# Install the dependencies
Write-Verbose -Message "Running paket.exe install"
Invoke-Expression "$PAKET_EXE restore"

# Make sure that Cake has been installed.
$CAKE_EXE = Resolve-Path $Cake
if (!(Test-Path $CAKE_EXE)) {
    Throw "Could not find Cake.exe at $CAKE_EXE"
}
Write-Verbose -Message "Found Cake.exe in PATH at $CAKE_EXE"

# Start Cake
Write-Host "Running build script..."
Invoke-Expression "& `"$CAKE_EXE`" `"$Script`" -target=`"$Target`" -configuration=`"$Configuration`" -verbosity=`"$Verbosity`" $UseMono $UseDryRun $UseExperimental $ScriptArgs"
exit $LASTEXITCODE