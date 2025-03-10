#Requires -Version 7
[CmdletBinding()] Param(
[Parameter(Mandatory=$true)][string] $BuildConfiguration,
[Parameter(Mandatory=$true)][string] $GalleryKey
)
dotnet publish -c:$BuildConfiguration
$proj = Get-ChildItem -Filter *.??proj -Recurse
$MSBuildProjectName = $proj.BaseName
Join-Path ($env:PSModulePath -split ';') $MSBuildProjectName |
    Where-Object {Test-Path $_ -Type Container} |
    Remove-Item -Recurse -Force -Verbose
Push-Location (Join-Path $proj.DirectoryName bin $BuildConfiguration publish)
Import-LocalizedData Module -FileName $MSBuildProjectName -BaseDirectory "$PWD"
$Version = $Module.ModuleVersion
$InstallPath = "$env:UserProfile/Documents/PowerShell/Modules/$MSBuildProjectName/$Version"
if(!(Test-Path $InstallPath -Type Container)) {mkdir $InstallPath}
Copy-Item * -Destination $InstallPath
Pop-Location
Publish-Module -Name $MSBuildProjectName -NuGetApiKey $GalleryKey
