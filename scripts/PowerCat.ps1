# ___________.__             ________         .__  .__                 __   
# \__    ___/|  |__   ____   \_____  \   ____ |  | |__| ____   _______/  |_ 
#   |    |   |  |  \_/ __ \   /   |   \ /    \|  | |  |/ __ \ /  ___/\   __\
#   |    |   |   Y  \  ___/  /    |    \   |  \  |_|  \  ___/ \___ \  |  |  
#   |____|   |___|  /\___  > \_______  /___|  /____/__|\___  >____  > |__|  
#                 \/     \/          \/     \/             \/     \/        
# /\        _____          __    __                   __  .__             /\
# \ \      /     \ _____ _/  |__/  |______    _______/  |_|__| ____      / /
#  \ \    /  \ /  \\__  \\   __\   __\__  \  /  ___/\   __\  |/ ___\    / / 
#   \ \  /    Y    \/ __ \|  |  |  |  / __ \_\___ \  |  | |  \  \___   / /  
#    \ \ \____|__  (____  /__|  |__| (____  /____  > |__| |__|\___  > / /   
#     \/         \/     \/                \/     \/               \/  \/    
#
#                                presents,
#
#                                PowerCat:
#                       A single‑shot concatenator 
#        for bundling markdown and code into one clean text file. 
# --------------------------------------------------------------------------
<#
.SYNOPSIS
Concatenate files from a source directory into a single output file.

.DESCRIPTION
PowerCat is a single-shot concatenator for bundling markdown and code into one clean text file.
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

.PARAMETER CatIgnore
Path to catignore file to exclude files/directories (similar to .gitignore).
If not specified, looks for 'catignore' in the source directory.

.PARAMETER NoCatIgnore
Skip reading the catignore file even if it exists.

.PARAMETER MinSize
Exclude files smaller than this size in bytes.

.PARAMETER MaxSize
Exclude files larger than this size in bytes.

.PARAMETER Minify
Remove comments and blank lines from output (strips lines starting with # or // and empty lines).

.PARAMETER HeaderFormat
Format for file headers: Markdown (default), JSON, or YAML.

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
License: GPL v3.0

.LINK
https://github.com/TheOnliestMattastic/PowerCat

.LINK
https://theonliestmattastic.github.io/ 
#>

param (
    [Parameter(Mandatory = $true, ParameterSetName = "Run", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("s")]
    [Alias("source")]
    [Alias("src")]
    [Alias("dir")]
    [Alias("FullName")]
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
    [string]$Sort = "Name",

    [Alias("ci")]
    [string]$CatIgnore,

    [Alias("nci")]
    [switch]$NoCatIgnore,

    [Alias("min")]
    [int64]$MinSize,

    [Alias("max")]
    [int64]$MaxSize,

    [Alias("mini")]
    [switch]$Minify,

    [Alias("hf")]
    [ValidateSet("Markdown", "JSON", "YAML")]
    [string]$HeaderFormat = "Markdown"
)

# Extend $Extensions based on switches
if ($Bash) { $Extensions += ".sh" }
if ($HTML) { $Extensions += ".html" }
if ($CSS) { $Extensions += ".css" }
if ($Powershell) { $Extensions += ".ps1" }
if ($Lua) { $Extensions += ".lua" }

# man-page
if ($Help) {
    Write-Output @"
PowerCat.ps1 — A single-shot concatenator for bundling markdown and code

USAGE:
    .\PowerCat.ps1 -s   <SourceDir> -o <OutputFile> [options]

REQUIRED PARAMETERS:
    -s, -SourceDir      Path to the directory containing files
    -o, -OutputFile     Path to the output text file

OPTIONS:
    -r, -Recurse        Include subdirectories
    -f, -Fence          Wrap file contents in Markdown code fences (i.e., '```')
    -e, -Extensions     Specify extensions (default: .md)
                        Example: -e ".ps1",".json",".sh"
    -st, -Sort          Sort by Name, Extension, LastWriteTime, or Length
    -ci, -CatIgnore     Path to catignore file (default: catignore in source dir)
    -nci, -NoCatIgnore  Skip reading catignore file
    -min, -MinSize      Exclude files smaller than this size in bytes
    -max, -MaxSize      Exclude files larger than this size in bytes
    -mini, -Minify      Remove comments and blank lines from output
    -hf, -HeaderFormat  Header format: Markdown (default), JSON, or YAML
    
    -b, -Bash           Include .sh files
    -c, -CSS            Include .css files
    -ht, -HTML          Include .html files
    -l, -Lua            Include .lua files
    -p, -PowerShell     Include .ps1 files

    -h, -Help           Show this help message

EXAMPLES:
    .\PowerCat.ps1 -s "C:\Project" -o "C:\bundle.txt"
    .\PowerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -r -l
    .\PowerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -e ".ps1",".json"

DESCRIPTION:
    PowerCat collects files by extension and concatenates them into a
    single text file. Useful for sharing code with LLMs, recruiters,
    or collaborators. Supports Markdown formatting for readability.
"@
    return
}
# Validate SourceDir
if (-not(Test-Path -Path $SourceDir)) { Write-Error "SourceDir '$SourceDir' not found." }

# Read catignore patterns
$IgnorePatterns = @()
if (-not $NoCatIgnore) {
    # Determine catignore file path
    if (-not $CatIgnore) {
        $CatIgnore = Join-Path -Path $SourceDir -ChildPath "catignore"
    }

    # Read patterns if catignore exists
    if (Test-Path -Path $CatIgnore) {
        $IgnorePatterns = @(Get-Content -Path $CatIgnore | 
            Where-Object { $_ -and -not $_.StartsWith('#') } |
            ForEach-Object { $_.Trim() })
    }
}

# Get all files in the directory 
$Files = foreach ($ext in $Extensions) {
    if ($Recurse) {
        Get-ChildItem -Path $SourceDir -Filter "*$ext" -File -Recurse
    }
    else {
        Get-ChildItem -Path $SourceDir -Filter "*$ext" -File
    }
}

# Filter out ignored files and by size
if ($IgnorePatterns.Count -gt 0 -or $MinSize -gt 0 -or $MaxSize -gt 0) {
    $Files = $Files | Where-Object {
        $file = $_
        $relativePath = $file.FullName.Substring($SourceDir.Length).TrimStart('\', '/')
        
        # Check catignore patterns
        $shouldIgnore = $false
        foreach ($pattern in $IgnorePatterns) {
            if ($relativePath -like $pattern -or $file.Name -like $pattern) {
                $shouldIgnore = $true
                break
            }
        }
        
        # Check size constraints
        if (-not $shouldIgnore) {
            if ($MinSize -gt 0 -and $file.Length -lt $MinSize) {
                $shouldIgnore = $true
            }
            elseif ($MaxSize -gt 0 -and $file.Length -gt $MaxSize) {
                $shouldIgnore = $true
            }
        }
        
        -not $shouldIgnore
    }
}

if ($Files.Count -eq 0) {
    Write-Output "No matching files found in $SourceDir"
    return
}

switch ($Sort) {
    "Name" { $Files = $Files | Sort-Object Name }
    "Extension" { $Files = $Files | Sort-Object Extension, Name }
    "LastWriteTime" { $Files = $Files | Sort-Object LastWriteTime }
    "Length" { $Files = $Files | Sort-Object Length }
}

# Clear OutputFile to prepare for concatenation
Remove-Item -Path $OutputFile -ErrorAction SilentlyContinue

# Concatenate contents into the output file
# Add a header before each file for clarity
foreach ($file in $Files) {
    # Generate header based on format
    $header = switch ($HeaderFormat) {
        "JSON" { ConvertTo-Json @{ file = $file.Name } -Compress }
        "YAML" { "file: {0}" -f $file.Name }
        default { "--- File: {0} ---" -f $file.Name }
    }
    Add-Content -Path $OutputFile -Value $header
    if (-not $Minify) {
        Add-Content -Path $OutputFile -Value ("`n")
    }

    # Open fence for -f flag
    if ($Fence) {
        Add-Content -Path $OutputFile -Value ('```{0}' -f $file.Extension.TrimStart('.'))
    }

    # Read file content and apply minification if requested
    $content = Get-Content -Path $file.FullName
    
    if ($Minify) {
        $content = $content | Where-Object {
            $_ -and -not ($_.TrimStart() -match '^[#//]')
        }
    }
    
    $content | Add-Content -Path $OutputFile

    # Close fence for -f flag
    if ($Fence) {
        Add-Content -Path $OutputFile -Value ('```') 
    }

    if (-not $Minify) {
        Add-Content -Path $OutputFile -Value ("`n")
    }
}

Write-Host "Concatenation complete. Output saved to $OutputFile"

# Return the output file object for pipeline support
Get-Item -Path $OutputFile