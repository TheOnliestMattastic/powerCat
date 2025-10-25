# Release Notes

```txt
___________.__             ________         .__  .__                 __   
\__    ___/|  |__   ____   \_____  \   ____ |  | |__| ____   _______/  |_ 
  |    |   |  |  \_/ __ \   /   |   \ /    \|  | |  |/ __ \ /  ___/\   __\
  |    |   |   Y  \  ___/  /    |    \   |  \  |_|  \  ___/ \___ \  |  |  
  |____|   |___|  /\___  > \_______  /___|  /____/__|\___  >____  > |__|  
                \/     \/          \/     \/             \/     \/        
   _____          __    __                   __  .__                      
  /     \ _____ _/  |__/  |______    _______/  |_|__| ____                
 /  \ /  \\__  \\   __\   __\__  \  /  ___/\   __\  |/ ___\               
/    Y    \/ __ \|  |  |  |  / __ \_\___ \  |  | |  \  \___               
\____|__  (____  /__|  |__| (____  /____  > |__| |__|\___  >              
        \/     \/                \/     \/               \/               
```

## Version 1.0.0 (2025-10-23)

### Overview

**powerCat** is a single‑shot concatenator for bundling markdown and code into one clean text file.
It’s the feline cousin of `cat`—polished for PowerShell, Markdown‑aware, and built with recruiter‑friendly ergonomics.

### Features

- **Concatenation:** Bundle multiple filetypes into a single output file.
- **Recursion:** Include subdirectories with `-Recurse`.
- **Markdown fences:** Opt‑in code fencing with `-Fence` for clean LLM/GitHub sharing.
- **Extensions:** Default as Markdown plus switches (`-Bash`, `-PowerShell`, `-HTML`, `-CSS`) or custom list via `-Extensions`.
- **Sorting:** Control order with `-Sort Name|Extension|LastWriteTime|Length`.
- **Aliases:** Quick commands `powerCat`, `pcat`, `concat` point to `Invoke-PowerCat`.
- **Native help:** Rich comment‑based help available via `Get-Help Invoke-PowerCat`.

### Added

- Initial release of powerCat.

## Version 1.0.6 (2025-10-25)

### Changed

- Changed license from CC0-1.0 to GPL v3.