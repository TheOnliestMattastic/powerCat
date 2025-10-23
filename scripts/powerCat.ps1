# ___________.__             ________         .__  .__                 __
# \__    ___/|  |__   ____   \_____  \   ____ |  | |__| ____   _______/  |_
#   |    |   |  |  \_/ __ \   /   |   \ /    \|  | |  |/ __ \ /  ___/\   __\
#   |    |   |   Y  \  ___/  /    |    \   |  \  |_|  \  ___/ \___ \  |  |
#   |____|   |___|  /\___  > \_______  /___|  /____/__|\___  >____  > |__|
#                 \/     \/          \/     \/             \/     \/
#    _____          __    __                   __  .__
#   /     \ _____ _/  |__/  |______    _______/  |_|__| ____
#  /  \ /  \\__  \\   __\   __\__  \  /  ___/\   __\  |/ ___\
# /    Y    \/ __ \|  |  |  |  / __ \_\___ \  |  | |  \  \___
# \____|__  (____  /__|  |__| (____  /____  > |__| |__|\___  >
#         \/     \/                \/     \/               \/
#
#                                presents,
#
#                                powerCat:
#                       A single‑shot concatenator 
#        for bundling markdown and code into one clean text file. 
# --------------------------------------------------------------------------
<#
.SYNOPSIS
Concatenate files from a source directory into a single output file.

.DESCRIPTION
powerCat is a single-shot concatenator for bundling markdown and code into one clean text file.
Supports recursion, Markdown code fencing, custom extensions, and sorting.

.PARAMETER SourceDir
Path to the directory containing files.

.PARAMETER OutputFile
Path to the output text file.

.PARAMETER Recurse
Include subdirectories.

.PARAMETER Fence
Wrap file contents in Markdown code fences (```).

.PARAMETER Extensions
Specify extensions to include (default: .md).
Example: -e ".ps1",".json",".sh"

.PARAMETER Bash
Include .sh files.

.PARAMETER HTML
Include .html files.

.PARAMETER Lua
Include .Lua files.

.PARAMETER CSS
Include .css files.

.PARAMETER PowerShell
Include .ps1 files.

.PARAMETER Sort
Property to sort files by (Name, Extension, LastWriteTime, Length).

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt"
Concatenates .md files from C:\Project into bundle.txt.

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -r -f
Recursively concatenates .md files and wraps them in Markdown fences.

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -b -p -sort Extension
Includes Bash and PowerShell files, sorted by extension.

.NOTES
Author: Matthew Poole Chicano
License: CC0-1.0

.LINK
https://github.com/TheOnliestMattastic/powerCat

.LINK
https://theonliestmattastic.github.io/
#>

param (
    [Parameter(Mandatory = $true, ParameterSetName = "Run")]
    [Alias("s")]
    [Alias("source")]
    [Alias("src")]
    [Alias("dir")]
    [string]$SourceDir,

    [Parameter(Mandatory = $true, ParameterSetName = "Run")]
    [Alias("o")]
    [Alias("out")]
    [Alias("output")]
    [Alias("file")]
    [string]$OutputFile,

    [Parameter(ParameterSetName = "Help")]
    [Alias("h")]
    [switch]$Help,

    [Alias("r")]
    [Alias("rec")]
    [Alias("recursive")]
    [switch]$Recurse,

    [Alias("l")]
    [Alias("lu")]
    [switch]$Lua,

    [Alias("b")]
    [Alias("sh")]
    [switch]$Bash,

    [Alias("ht")]
    [Alias("htm")]
    [switch]$HTML,

    [Alias("c")]
    [Alias("cs")]
    [switch]$CSS,

    [Alias("p")]
    [Alias("ps")]
    [Alias("ps1")]
    [switch]$Powershell,

    [Alias("e")]
    [Alias("ex")]
    [Alias("ext")]
    [string[]]$Extensions = @(".md"), # default

    [Alias("f")]
    [Alias("fen")]
    [switch]$Fence,

    [Alias("st")]
    [ValidateSet("Name", "Extension", "LastWriteTime", "Length")]
    [string]$Sort = "Name"
)

# Extend $Extensions based on switches
if ($Bash)          { $Extensions += ".sh" }
if ($HTML)          { $Extensions += ".html" }
if ($CSS)           { $Extensions += ".css" }
if ($Powershell)    { $Extensions += ".ps1" }
if ($Lua)           { $Extensions += ".lua"}

# man-page
if ($Help) {
    Write-Output @"
powerCat.ps1 — A single-shot concatenator for bundling markdown and code

USAGE:
    .\powerCat.ps1 -s   <SourceDir> -o <OutputFile> [options]

REQUIRED PARAMETERS:
    -s, -SourceDir      Path to the directory containing files
    -o, -OutputFile     Path to the output text file

OPTIONS:
    -r, -Recurse        Include subdirectories
    -f, -Fence          Wrap file contents in Markdown code fences (i.e., '```')
    -e, -Extensions     Specify extensions (default: .md)
                        Example: -e ".ps1",".json",".sh"

    -b, -Bash           Include .sh files
    -c, -CSS            Include .css files
    -ht, -HTML          Include .html files
    -l, -Lua            Include .lua files
    -p, -PowerShell     Include .ps1 files

    -h, -Help           Show this help message

EXAMPLES:
    .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt"
    .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -r -l
    .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -e ".ps1",".json"

DESCRIPTION:
    powerCat collects files by extension and concatenates them into a
    single text file. Useful for sharing code with LLMs, recruiters,
    or collaborators. Supports Markdown formatting for readability.
"@
    return
}
# Validate SourceDir
if(-not(Test-Path -Path $SourceDir)){Write-Error "SourceDir '$SourceDir' not found."}

# Get all files in the directory 
$Files = foreach ($ext in $Extensions) {
    if ($Recurse) {
        Get-ChildItem -Path $SourceDir -Filter "*$ext" -File -Recurse
    } else {
        Get-ChildItem -Path $SourceDir -Filter "*$ext" -File
    }
}

if ($Files.Count -eq 0) {
    Write-Output "No matching files found in $SourceDir"
    return
}

switch ($Sort) {
    "Name"          { $Files = $Files | Sort-Object Name }
    "Extension"     { $Files = $Files | Sort-Object Extension, Name }
    "LastWriteTime" { $Files = $Files | Sort-Object LastWriteTime }
    "Length"        { $Files = $Files | Sort-Object Length }
}

# Clear OutputFile to prepare for concatenation
Remove-Item -Path $OutputFile -ErrorAction SilentlyContinue

# Concatenate contents into the output file
# Add a header before each file for clarity
foreach ($file in $Files) {
    Add-Content -Path $OutputFile -Value ("--- File: {0} ---" -f $file.Name)
    Add-Content -Path $OutputFile -Value ("`n")

    # Open fence for -f flag
    if ($Fence) {
        Add-Content -Path $OutputFile -Value ('```{0}' -f $file.Extension.TrimStart('.'))
    }

    Get-Content -Path $file.FullName | Add-Content -Path $OutputFile

    # Close fence for -f flag
    if ($Fence) {
        Add-Content -Path $OutputFile -Value ('```') 
    }

    Add-Content -Path $OutputFile -Value ("`n")
}

Write-Host "Concatenation complete. Output saved to $OutputFile"