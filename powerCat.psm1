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
#                       A single-shot concatenator 
#                       for bundling code and docs
# --------------------------------------------------------------------------
# How to use this script:
# 1. Run with required parameters: -SourceDir and -OutputFile
#    Example: .\powerCat.ps1 -s "C:\pat\to\dir" -o "C:\path\to\file.txt"
# 2. (Optional) Add switches like -r (recursive), -ht (html), or -e (extensions)
# 3. Output will contain all matching files concatenated into one text file
# --------------------------------------------------------------------------
param (
    [Parameter(Mandatory = $true)]
    [Alias("s")]
    [Alias("source")]
    [Alias("dir")]
    [string]$SourceDir,

    [Parameter(Mandatory = $true)]
    [Alias("o")]
    [Alias("out")]
    [Alias("output")]
    [Alias("file")]
    [string]$OutputFile,

    [Alias("h")]
    [switch]$Help,

    [Alias("r")]
    [Alias("rec")]
    [Alias("recursive")]
    [switch]$Recurse,

    [Alias("m")]
    [Alias("md")]
    [switch]$Markdown,

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
    [string[]]$Extensions = @(".lua"), # default

    [Alias("f")]
    [Alias("fen")]
    [switch]$Fence,

    [Alias("sort")]
    [ValidateSet("Name", "Extension", "LasWriteTime", "Length")]
    [string]$Sort = "Name"
)

# Extend $Extensions based on switches
if ($Bash)          { $Extensions += ".sh" }
if ($HTML)          { $Extensions += ".html" }
if ($CSS)           { $Extensions += ".css" }
if ($Powershell)    { $Extensions += ".css" }
if ($Markdown)      { $Extensions += ".md" }

# man-page
if ($Help) {
    Write-Host @"
powerCat.ps1 — A single-shot concatenator for bundling code and docs

USAGE:
    .\powerCat.ps1 -s   <SourceDir> -o <OutputFile> [options]

REQUIRED PARAMETERS:
    -s, -SourceDir      Path to the directory containing files
    -o, -OutputFile     Path to the output text file

OPTIONS:
    -r, -Recurse        Include subdirectories
    -f, -Fence          Wrap file contents in Markdown code fences (i.e., '```')
    -e, -Extensions     Specify extensions (default: .lua, .md)
                        Example: -e ".ps1",".json",".sh"

    -b, -Bash           Include .sh files
    -c, -CSS            Include .css files
    -ht, -HTML          Include .html files
    -m, -Markdown       Include .md files
    -p, -PowerShell     Include .ps1 files

    -h, -Help           Show this help message

EXAMPLES:
    .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt"
    .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -r -m
    .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -e ".ps1",".json"

DESCRIPTION:
    powerCat collects files by extension and concatenates them into a
    single text file. Useful for sharing code with LLMs, recruiters,
    or collaborators. Supports Markdown formatting for readability.
"@
    exit
}

# Get all files in the directory 
$Files = foreach ($ext in $Extensions) {
    if ($Recurse) {
        Get-ChildItem -Path $SourceDir -Filter "*$ext" -File -Recurse
    } else {
        Get-ChildItem -Path $SourceDir -Filter "*$ext" -File
    }
}

if ($Files.Count -eq 0) {
    Write-Host "No matching files found in $SourceDir"
    exit
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