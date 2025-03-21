<#
.SYNOPSIS
Publishes a module to PowerShell gallery.
#>

#Requires -Version 7
[CmdletBinding()] Param(
[Parameter(Mandatory=$true)][string] $BuildConfiguration,
[Parameter(Mandatory=$true)][string] $GalleryKey
)
"- &#x1F3D7; Build config $BuildConfiguration" >> $GITHUB_STEP_SUMMARY
dotnet publish -c:$BuildConfiguration
$proj = Get-ChildItem -Filter *.??proj -Recurse |Select-Object -First 1
$Name = $proj.BaseName
"::notice file=$($proj.FullName),title=${Name}::Project"
Join-Path ($env:PSModulePath -split ';') $Name |
	Where-Object {Test-Path $_ -Type Container} |
	Remove-Item -Recurse -Force -Verbose
Get-ChildItem $proj.DirectoryName -Filter publish -Directory -Recurse |Push-Location
Import-LocalizedData Module -FileName $Name -BaseDirectory "$PWD"
$Version = $Module.ModuleVersion
$InstallPath = Join-Path $env:UserProfile Documents PowerShell Modules $Name $Version
if(!(Test-Path $InstallPath -Type Container)) {New-Item -Type Directory $InstallPath |Out-Null}
"- &#x1F4E6; Stage to $InstallPath" >> $GITHUB_STEP_SUMMARY
Copy-Item * -Destination $InstallPath -Verbose
"::notice file=$InstallPath\$Name.psd1,title=${Name}::Installed module"
Pop-Location
"- :rocket: Publish $Name v$Version" >> $GITHUB_STEP_SUMMARY
"::notice file=$GITHUB_STEP_SUMMARY,title=Summary::Publish summary"
Publish-Module -Name $Name -NuGetApiKey $GalleryKey
