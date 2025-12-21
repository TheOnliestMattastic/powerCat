# =============================================================================
#              ▄ ▄                                   ▄                         
#            █ ▀ ▀ █ ██████ ▄▄ ▄▄ ▄▄▄▄▄   ▄█▀▀▀▀█ ▄  ▀          ▄    ▄▄▄    ▄  
#           █       █  ██   ██▄██ ██▄▄    █  █▀▄   ▀▄ ▄▄▄ ▄▄▄    ▀▄ ██▀██ ▄▀   
#          █  ▄▄▄▄▄  █ ██   ██ ██ ██▄▄▄   █▄ ▀▀ █ ▄▀  ▄         ▄▀  ▀███▀  ▀▄  
#        ▄ ▄         ▄ ▄                   ▀▀▀▀▀     ▀                         
#      █ ▀ ▀ █     █ ▀ ▀ █   ▄████▄ ▄▄  ▄▄ ▄▄    ▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄▄▄▄▄         
#     █       █   █       █  ██  ██ ███▄██ ██    ██ ██▄▄  ███▄▄   ██           
#    █  ▄▄▄▄▄  █ █  ▄▄▄▄▄  █ ▀████▀ ██ ▀██ ██▄▄▄ ██ ██▄▄▄ ▄▄██▀   ██           
#                                                                              
#    ▄    ▄▄▄    ▄ ██▄  ▄██ ▄████▄ ██████ ██████ ▄▄▄   ▄▄▄▄ ▄▄▄▄▄▄ ▄▄  ▄▄▄▄    
#     ▀▄ ██▀██ ▄▀  ██ ▀▀ ██ ██▄▄██   ██     ██  ██▀██ ███▄▄   ██   ██ ██▀▀▀    
#    ▄▀  ▀███▀  ▀▄ ██    ██ ██  ██   ██     ██  ██▀██ ▄▄██▀   ██   ██ ▀████    
# =============================================================================
<#
.SYNOPSIS
Concatenate files from a source directory to stdout or output file.

.DESCRIPTION
PowerCat is a single-shot concatenator for bundling markdown and code into one clean text file.
Outputs to stdout by default (Unix cat style); optional file writing via -OutputFile.
Supports recursion, Markdown code fencing, custom extensions, sorting, minification, and token estimation.

.PARAMETER SourceDir
Path to the directory containing files.

.PARAMETER OutputFile
Path to the output text file (optional). If not specified, output streams to stdout.

.PARAMETER Recurse
Include subdirectories.

.PARAMETER Fence
Wrap file contents in Markdown code fences (```).

.PARAMETER Extensions
Specify extensions to include (default: none — opt-in).
Example: -e ".ps1",".json",".sh"

.PARAMETER IncludeMarkdown
When set, explicitly include `.md` files in the selection. This replaces the previous implicit inclusion of Markdown files.

.PARAMETER Bash
Include .sh files.

.PARAMETER HTML
Include .html files.

.PARAMETER Lua
Include .lua files.

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

.PARAMETER Stats
Display statistics: file count, character count, and estimated token usage (for AI context planning).

.EXAMPLE
.\PowerCat.ps1 "C:\Project"
Outputs matching files to stdout (no implicit Markdown). Use `-IncludeMarkdown` to include `.md` files.

.EXAMPLE
.\PowerCat.ps1 "C:\Project" -o "C:\bundle.txt"
Writes matching files to bundle.txt (use `-IncludeMarkdown` to include `.md`).

.EXAMPLE
.\PowerCat.ps1 "C:\Project" -o "C:\bundle.txt" -r -f -p
Recursively concatenates .ps1 files with Markdown fences, writes to bundle.txt.

.EXAMPLE
.\PowerCat.ps1 "C:\Project" -st
Displays file count, character count, and estimated token usage.

.NOTES
Author: Matthew Poole Chicano
License: GPL v3.0

.LINK
https://github.com/TheOnliestMattastic/PowerCat

.LINK
https://theonliestmattastic.github.io/
#>

<# DEPRECATION NOTICE
Note: PowerCat previously included `.md` files by default. That implicit behaviour is deprecated.
PowerCat now requires explicit extension selection. Use the `-IncludeMarkdown` switch to opt-in
to including `.md` files, or specify `-Extensions ".md"` explicitly. This makes automated
workflows safer and avoids accidental inclusion of documentation files.
#>

param (
  [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Run", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [Alias("s")]
  [Alias("source")]
  [Alias("src")]
  [Alias("dir")]
  [Alias("FullName")]
  [string]$SourceDir,

  [Parameter(ParameterSetName = "Run")]
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
  [string[]]$Extensions = @(), # default: none (opt-in)

  [Alias("im")]
  [Alias("m")]
  [switch]$IncludeMarkdown,

  [Alias("excl")]
  [string[]]$ExcludeExtensions = @(),

  [Alias("force")]
  [switch]$ForceOverwrite,

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
  [ValidateRange(0, [int64]::MaxValue)]
  [int64]$MinSize = 0,

  [Alias("max")]
  [ValidateRange(0, [int64]::MaxValue)]
  [int64]$MaxSize = 0,

  [Alias("mini")]
  [switch]$Minify,

  [Alias("hf")]
  [ValidateSet("Markdown", "JSON", "YAML")]
  [string]$HeaderFormat = "Markdown",

  [Alias("sta")]
  [switch]$Stats
)

# Extend $Extensions based on switches
if ($Bash) { $Extensions += ".sh" }
if ($HTML) { $Extensions += ".html" }
if ($CSS) { $Extensions += ".css" }
if ($Powershell) { $Extensions += ".ps1" }
if ($Lua) { $Extensions += ".lua" }
if ($IncludeMarkdown) { $Extensions += ".md" }

# Allow comma-separated single string entries in -Extensions
$Extensions = $Extensions | ForEach-Object {
  if ($_ -is [string] -and $_ -like "*,*") {
    ($_ -split ',') | ForEach-Object { $_.Trim() }
  }
  else {
    $_
  }
}
$Extensions = $Extensions | Where-Object { $_ } | Select-Object -Unique

# Normalize excluded extensions and remove them
if ($ExcludeExtensions.Count -gt 0) {
  $exclude = $ExcludeExtensions | ForEach-Object {
    if ($_ -is [string] -and $_ -like "*,*") { ($_ -split ',') | ForEach-Object { $_.Trim() } } else { $_ }
  } | Where-Object { $_ } | Select-Object -Unique
  $Extensions = $Extensions | Where-Object { $exclude -notcontains $_ }
}

# Man-page help
if ($Help) {
  Write-Output @"
PowerCat.ps1 — A single-shot concatenator for bundling markdown and code

USAGE:
  .\PowerCat.ps1 <SourceDir> [-o <OutputFile>] [options]

REQUIRED PARAMETERS:
  <SourceDir> (positional) Path to the directory containing files
  -s, -SourceDir      Alias for positional `SourceDir`

OPTIONAL PARAMETERS:
    -o, -OutputFile     Path to the output text file (default: stdout)

OPTIONS:
    -r, -Recurse        Include subdirectories
    -f, -Fence          Wrap file contents in Markdown code fences
    -e, -Extensions     Specify extensions (default: none — opt-in)
              Example: -e ".ps1",".json",".sh"
    -im, -IncludeMarkdown Explicitly include `.md` files (useful for restoring legacy behavior)
    -st, -Sort          Sort by Name, Extension, LastWriteTime, or Length
    -ci, -CatIgnore     Path to catignore file (default: catignore in source dir)
    -nci, -NoCatIgnore  Skip reading catignore file
    -min, -MinSize      Exclude files smaller than this size in bytes
    -max, -MaxSize      Exclude files larger than this size in bytes
    -mini, -Minify      Remove comments and blank lines from output
    -hf, -HeaderFormat  Header format: Markdown (default), JSON, or YAML
    -sta, -Stats        Display file count, character count, and token estimate
    
    -b, -Bash           Include .sh files
    -c, -CSS            Include .css files
    -ht, -HTML          Include .html files
    -l, -Lua            Include .lua files
    -p, -PowerShell     Include .ps1 files

    -h, -Help           Show this help message

.EXAMPLE
.\PowerCat.ps1 "C:\Project"
Outputs matching files to stdout (no implicit Markdown). Use `-IncludeMarkdown` to include `.md` files.
.EXAMPLE
.\PowerCat.ps1 "C:\Project" -o "C:\bundle.txt"
Writes matching files to bundle.txt (use `-IncludeMarkdown` to include `.md`).
.EXAMPLE
.\PowerCat.ps1 "C:\Project" -o "C:\bundle.txt" -r -f -p
Recursively concatenates .ps1 files with Markdown fences, writes to bundle.txt.
    Supports Markdown formatting, code fencing, minification, and token
    estimation for LLM integration.
"@
  return
}

# Expand paths (handle ~, relative paths, etc.)
$SourceDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($SourceDir)
if ($OutputFile) {
  $OutputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFile)
}

# Validate SourceDir
if (-not(Test-Path -Path $SourceDir)) { 
  Write-Error "SourceDir '$SourceDir' not found."
  exit 1
}

# Validate OutputFile path is writable (only if OutputFile is specified)
if ($OutputFile) {
  $OutputDir = Split-Path -Path $OutputFile -Parent
  if (-not $OutputDir) { $OutputDir = "." }
  if (-not(Test-Path -Path $OutputDir)) {
    Write-Error "Output directory '$OutputDir' does not exist."
    exit 1
  }
  if (-not(Test-Path -Path $OutputDir -PathType Container)) {
    Write-Error "Output path '$OutputDir' is not a directory."
    exit 1
  }

  # Check if we can write to the output directory
  try {
    $testFile = Join-Path -Path $OutputDir -ChildPath ".powercat_write_test_$([System.IO.Path]::GetRandomFileName())"
    [System.IO.File]::WriteAllText($testFile, "test")
    Remove-Item -Path $testFile -Force
  }
  catch {
      if (-not $ForceOverwrite) {
        Write-Error "Output directory '$OutputDir' is not writable: $_"
        exit 1
      }
  }

    # If output file exists and ForceOverwrite specified, attempt to remove it
    if ($OutputFile -and (Test-Path -Path $OutputFile) -and $ForceOverwrite) {
      try { Remove-Item -Path $OutputFile -Force -ErrorAction Stop } catch { }
    }
}

# Read catignore patterns
$IgnorePatterns = @()
if (-not $NoCatIgnore) {
  # Determine catignore file path
  if (-not $CatIgnore) {
    $CatIgnore = Join-Path -Path $SourceDir -ChildPath "catignore"
  }
  else {
    # Expand user-provided catignore path
    $CatIgnore = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CatIgnore)
  }

  # Read patterns if catignore exists
  if (Test-Path -Path $CatIgnore) {
    $IgnorePatterns = @(Get-Content -Path $CatIgnore | 
      Where-Object { $_ -and -not $_.StartsWith('#') } |
      ForEach-Object { $_.Trim() })
  }
}

# Get all files in the directory (single scan, filter by extension in PowerShell)
$getChildItemParams = @{
  Path = $SourceDir
  File = $true
}
if ($Recurse) {
  $getChildItemParams['Recurse'] = $true
}

$Files = @(Get-ChildItem @getChildItemParams) | 
Where-Object { $Extensions -contains $_.Extension }

# If no extensions selected, return early with a helpful message
if ($Extensions.Count -eq 0) {
  Write-Output "No extensions selected. Use -Extensions, -IncludeMarkdown, or switches like -PowerShell to select file types."
  exit 0
}
# Filter out ignored files and by size
if ($IgnorePatterns.Count -gt 0 -or $MinSize -gt 0 -or $MaxSize -gt 0) {
  $Files = $Files | Where-Object {
    $file = $_
    $sourceDirPath = $SourceDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $relativePath = $file.FullName.Substring($sourceDirPath.Length).TrimStart('\', '/')
        
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

# Filter out binary files to prevent crashes
$binaryExtensions = @('.exe', '.dll', '.bin', '.zip', '.rar', '.7z', '.gz', '.tar', '.iso',
  '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.ico', '.webp',
  '.mp3', '.mp4', '.avi', '.mov', '.mkv', '.flv',
  '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
  '.db', '.sqlite', '.mdb', '.pyc', '.class', '.o', '.so', '.dylib')

$Files = $Files | Where-Object {
  if ($binaryExtensions -contains $_.Extension.ToLower()) {
    Write-Warning "Skipping binary file: $($_.FullName)"
    return $false
  }
  return $true
}

if ($Files.Count -eq 0) {
  Write-Output "No matching text files found in $SourceDir"
  exit 0
}

switch ($Sort) {
  "Name" { $Files = $Files | Sort-Object Name }
  "Extension" { $Files = $Files | Sort-Object Extension, Name }
  "LastWriteTime" { $Files = $Files | Sort-Object LastWriteTime }
  "Length" { $Files = $Files | Sort-Object Length }
}

# Build output content in a string array for efficiency
$OutputContent = @()

foreach ($file in $Files) {
  # Generate header based on format
  $header = switch ($HeaderFormat) {
    "JSON" { ConvertTo-Json @{ file = $file.Name } -Compress }
    "YAML" { "file: {0}" -f $file.Name }
    default { "--- File: {0} ---" -f $file.Name }
  }
  $OutputContent += $header
    
  if (-not $Minify) {
    $OutputContent += ""
  }

  # Open fence for -f flag
  if ($Fence) {
    $OutputContent += '```{0}' -f $file.Extension.TrimStart('.')
  }

  # Read file content with UTF-8 encoding (cross-platform compatibility)
  try {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction Stop
        
    if ($Minify) {
      $content = $content | Where-Object {
        $trimmed = $_.TrimStart()
        # Skip empty lines and comment lines (# or //)
        if ($trimmed) {
          -not ($trimmed -match '^#' -or $trimmed -match '^//')
        }
        else {
          $false
        }
      }
    }
        
    $OutputContent += $content
  }
  catch {
    Write-Warning "Failed to read file '$($file.FullName)': $_"
    continue
  }

  # Close fence for -f flag
  if ($Fence) {
    $OutputContent += '```'
  }

  if (-not $Minify) {
    $OutputContent += ""
  }
}

# Write to file or stdout based on OutputFile parameter
if ($OutputFile) {
  try {
    $OutputContent | Set-Content -Path $OutputFile -Encoding UTF8 -ErrorAction Stop
  }
  catch {
    Write-Error "Failed to write output file '$OutputFile': $_"
    exit 1
  }
    
  # Return the output file object for pipeline support
  Get-Item -Path $OutputFile
}
else {
  # Output to stdout (matching Unix cat behavior)
  $OutputContent | Write-Output
}

# Calculate stats if requested
if ($Stats) {
  $outputText = $OutputContent -join "`n"
  $charCount = $outputText.Length
  # Token estimation: ~4 characters per token (varies by model; GPT-3.5/4 use this baseline)
  $estimatedTokens = [Math]::Ceiling($charCount / 4)
    
  Write-Output "=== PowerCat Statistics ==="
  Write-Output "Files processed:     $($Files.Count)"
  Write-Output "Total characters:    $charCount"
  Write-Output "Estimated tokens:    $estimatedTokens (4 chars/token baseline)"
  Write-Output "==========================="
}