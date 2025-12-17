# Release Notes

```txt
 ███████████ █████                                                                       
░█░░░███░░░█░░███                                                                        
░   ░███  ░  ░███████    ██████                                                          
    ░███     ░███░░███  ███░░███                                                         
    ░███     ░███ ░███ ░███████                                                          
    ░███     ░███ ░███ ░███░░░                                                           
    █████    ████ █████░░██████                                                          
   ░░░░░    ░░░░ ░░░░░  ░░░░░░                                                           
                                                                                         
    ███████               ████   ███                    █████                            
  ███░░░░░███            ░░███  ░░░                    ░░███                             
 ███     ░░███ ████████   ░███  ████   ██████   █████  ███████                           
░███      ░███░░███░░███  ░███ ░░███  ███░░███ ███░░  ░░░███░                            
░███      ░███ ░███ ░███  ░███  ░███ ░███████ ░░█████   ░███                             
░░███     ███  ░███ ░███  ░███  ░███ ░███░░░   ░░░░███  ░███ ███                         
 ░░░███████░   ████ █████ █████ █████░░██████  ██████   ░░█████                          
   ░░░░░░░    ░░░░ ░░░░░ ░░░░░ ░░░░░  ░░░░░░  ░░░░░░     ░░░░░                           
                                                                                         
 ██████   ██████            █████     █████                       █████     ███          
░░██████ ██████            ░░███     ░░███                       ░░███     ░░░           
 ░███░█████░███   ██████   ███████   ███████    ██████    █████  ███████   ████   ██████ 
 ░███░░███ ░███  ░░░░░███ ░░░███░   ░░░███░    ░░░░░███  ███░░  ░░░███░   ░░███  ███░░███
 ░███ ░░░  ░███   ███████   ░███      ░███      ███████ ░░█████   ░███     ░███ ░███ ░░░ 
 ░███      ░███  ███░░███   ░███ ███  ░███ ███ ███░░███  ░░░░███  ░███ ███ ░███ ░███  ███
 █████     █████░░████████  ░░█████   ░░█████ ░░████████ ██████   ░░█████  █████░░██████ 
░░░░░     ░░░░░  ░░░░░░░░    ░░░░░     ░░░░░   ░░░░░░░░ ░░░░░░     ░░░░░  ░░░░░  ░░░░░░  
```

## Version 1.0.0 (2025-10-23)

### Overview

**PowerCat** is a single‑shot concatenator for bundling markdown and code into one clean text file.
It’s the feline cousin of `cat`—polished for PowerShell, Markdown‑aware, and built with recruiter‑friendly ergonomics.

### Features

- **Concatenation:** Bundle multiple filetypes into a single output file.
- **Recursion:** Include subdirectories with `-Recurse`.
- **Markdown fences:** Opt‑in code fencing with `-Fence` for clean LLM/GitHub sharing.
- **Extensions:** Default as Markdown plus switches (`-Bash`, `-PowerShell`, `-HTML`, `-CSS`) or custom list via `-Extensions`.
- **Sorting:** Control order with `-Sort Name|Extension|LastWriteTime|Length`.
- **Aliases:** Quick commands `PowerCat`, `pcat`, `concat` point to `Invoke-PowerCat`.
- **Native help:** Rich comment‑based help available via `Get-Help Invoke-PowerCat`.

### Added

- Initial release of PowerCat.

## Version 1.0.6 (2025-10-25)

### Changed

- Changed license from CC0-1.0 to GPL v3.

## Version 1.1.0 (2025-11-08)

### Added

- **Minify parameter** (`-Minify`, `-mini`): Remove comments and blank lines from output for cleaner code bundles.
- **HeaderFormat parameter** (`-HeaderFormat`, `-hf`): Specify output header format—Markdown (default), JSON, or YAML.
- **MinSize parameter** (`-MinSize`, `-min`): Exclude files smaller than specified size in bytes.
- **MaxSize parameter** (`-MaxSize`, `-max`): Exclude files larger than specified size in bytes.

### Fixed

- Fixed Pester tests for cross-platform compatibility (Linux/macOS/Windows).
- Updated module import paths to use forward slashes (`/`) instead of backslashes (`\`).
- Replaced `$env:TEMP` with `/tmp` for Linux systems where environment variable is unavailable.
- Added `-Raw` flag to `Get-Content` calls for proper multi-line regex matching in test assertions.

### Improved

- Enhanced test robustness across different operating systems.
- All 16 Pester tests now pass on Linux systems.
- Comprehensive test coverage for new features (minification, custom headers, size filtering).

## Version 1.1.1 (2025-11-08)

### Added

- **Binary file detection:** Automatically skips common binary formats (`.exe`, `.dll`, `.zip`, images, media, archives, databases, etc.) to prevent concatenation errors.
- **Output directory validation:** Verifies output directory exists and is writable before processing files.
- **Parameter validation:** Added `ValidateRange` attributes to `-MinSize` and `-MaxSize` for input integrity.

### Fixed

- Fixed minify filter regex from character class `[#//]` (matching individual characters) to explicit patterns `^#` and `^//` for proper comment filtering.
- Improved path separator handling with `DirectorySeparatorChar` and `AltDirectorySeparatorChar` for better cross-platform compatibility.
- Fixed `-MinSize` validation logic (changed from `-ne 0` to `-gt 0`).
- Added path expansion for user-provided `-CatIgnore` parameter (supports `~` and relative paths).

### Improved

- **Efficiency:** Refactored file reading loop to use single `Get-ChildItem` scan instead of per-extension loops; consolidated output into string array and write once with `Set-Content`.
- **Error handling:** Added comprehensive try-catch blocks around file I/O operations with descriptive error messages.
- **UTF-8 encoding:** Specified UTF-8 encoding for all file reads and writes for consistent cross-platform text handling (no BOM).
- **Module ergonomics:** Removed `-Help` switch from module (PowerShell-idiomatic); users rely on `Get-Help Invoke-PowerCat` for native PowerShell help discovery.
- **Cross-platform paths:** Added `GetUnresolvedProviderPathFromPSPath` for proper tilde (`~`) and relative path expansion on all platforms.

## Version 1.2.0 (2025-12-17)

### Changed

- **Breaking change:** `-OutputFile` parameter is now optional (was mandatory). Default behavior outputs to stdout, matching Unix `cat` convention.
- Removed confirmation message from file output (`Write-Host`).

### Added

- **Stdout output:** Invoke-PowerCat now outputs concatenated content to stdout by default, enabling Unix-style piping and redirection.
  - Example: `Invoke-PowerCat -s ./src | Out-File bundle.txt` (manual redirection)
  - Example: `Invoke-PowerCat -s ./src -o bundle.txt` (direct file output, optional)

### Fixed

- Fixed `-OutputFile` path expansion to only occur when parameter is provided, preventing erroneous directory resolution on stdout-only invocations.
- Corrected test suite to validate both stdout and file-output behaviors.

