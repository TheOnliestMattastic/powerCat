<#
.SYNOPSIS
Concatenate files from a source directory into a single output file.

.DESCRIPTION
PowerCat is a single-shot concatenator for bundling markdown and code into one clean text file.
Supports recursion, Markdown code fencing, custom extensions, and sorting.

.PARAMETER SourceDir
Path to the directory containing files.

.PARAMETER OutputFile
Path to the output text file. If not specified, output is written to stdout (like Unix cat).

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

.PARAMETER Stats
Display statistics: file count, character count, and estimated token usage (for AI context planning).

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt"
Concatenates .md files from C:\Project into bundle.txt.

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -r -f
Recursively concatenates .md files and wraps them in Markdown fences.

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -b -p -sort Extension
Includes Bash and PowerShell files, sorted by extension.

.EXAMPLE
Invoke-PowerCat -s "C:\Project" -sta
Displays file count, character count, and estimated token usage (useful for AI context planning).

.NOTES
Author: Matthew Poole Chicano
License: GPL v3.0

.LINK
https://github.com/TheOnliestMattastic/PowerCat

.LINK
https://theonliestmattastic.github.io/
#>
function Invoke-PowerCat {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = "Run", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
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
  $Extensions = $Extensions | Select-Object -Unique

  # Expand paths (handle ~, relative paths, etc.)
  $SourceDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($SourceDir)
  if ($OutputFile) {
    $OutputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFile)
  }

  # Validate SourceDir
  if (-not(Test-Path -Path $SourceDir)) { 
    Write-Error "SourceDir '$SourceDir' not found."
    return
  }

  # Validate OutputFile path is writable (only if OutputFile is specified)
  if ($OutputFile) {
    $OutputDir = Split-Path -Path $OutputFile -Parent
    if (-not $OutputDir) { $OutputDir = "." }
    if (-not(Test-Path -Path $OutputDir)) {
      Write-Error "Output directory '$OutputDir' does not exist."
      return
    }
    if (-not(Test-Path -Path $OutputDir -PathType Container)) {
      Write-Error "Output path '$OutputDir' is not a directory."
      return
    }

    # Check if we can write to the output directory
    try {
      $testFile = Join-Path -Path $OutputDir -ChildPath ".powercat_write_test_$([System.IO.Path]::GetRandomFileName())"
      [System.IO.File]::WriteAllText($testFile, "test")
      Remove-Item -Path $testFile -Force
    }
    catch {
      Write-Error "Output directory '$OutputDir' is not writable: $_"
      return
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
    return
  } 
  else {
    $Files = $Files | Select-Object -Unique
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
      return
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
}
# --- Aliases ---
Set-Alias -Name PowerCat -Value Invoke-PowerCat
Set-Alias -Name pcat -Value Invoke-PowerCat
Set-Alias -Name concat -Value Invoke-PowerCat
Export-ModuleMember -Function Invoke-PowerCat -Alias PowerCat, pcat, concat