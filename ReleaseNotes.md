# Release Notes

```txt
 ___________.__             ________         .__  .__                 __   
 \__    ___/|  |__   ____   \_____  \   ____ |  | |__| ____   _______/  |_ 
   |    |   |  |  \_/ __ \   /   |   \ /    \|  | |  |/ __ \ /  ___/\   __\
   |    |   |   Y  \  ___/  /    |    \   |  \  |_|  \  ___/ \___ \  |  |  
   |____|   |___|  /\___  > \_______  /___|  /____/__|\___  >____  > |__|  
                 \/     \/          \/     \/             \/     \/        
 /\        _____          __    __                   __  .__             /\
 \ \      /     \ _____ _/  |__/  |______    _______/  |_|__| ____      / /
  \ \    /  \ /  \\__  \\   __\   __\__  \  /  ___/\   __\  |/ ___\    / / 
   \ \  /    Y    \/ __ \|  |  |  |  / __ \_\___ \  |  | |  \  \___   / /  
    \ \ \____|__  (____  /__|  |__| (____  /____  > |__| |__|\___  > / /   
     \/         \/     \/                \/     \/               \/  \/    
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