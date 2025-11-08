# AGENTS.md — Amp Configuration for PowerCat

This file documents conventions and commands for AI agents working on the PowerCat project.

## Project Overview

**PowerCat** is a single-shot concatenator for bundling markdown and code into one clean text file. It's written in PowerShell and ships as both a module and a standalone script.

- **Module:** `src/PowerCat/PowerCat.psm1`, `src/PowerCat/PowerCat.psd1`
- **Script:** `scripts/PowerCat.ps1`
- **Tests:** Pester tests (location: `tests/`)
- **License:** GPL v3.0

## Code Style & Conventions

### PowerShell

- **Naming:** Use PascalCase for function names and parameters, camelCase for variables.
- **Documentation:** Use comment-based help blocks (see `PowerCat.ps1` for examples).
- **Parameters:** Use aliases for common shortcuts (e.g., `-s` for `-SourceDir`).
- **Formatting:** Keep lines clean and readable; use consistent indentation (4 spaces).

### Markdown

- Use H2 headings (`##`) for main sections.
- Include ASCII art header when appropriate (see README, RELEASING, ReleaseNotes examples).
- Use badges for CI status and package links (see README).

## Common Tasks & Commands

### Testing

```powershell
# Run all Pester tests
Invoke-Pester -Path tests/
```

### Running the Module

```powershell
# Import the module
Import-Module .\src\PowerCat.psd1 -Force

# Run the function
Invoke-PowerCat -SourceDir "." -OutputFile "bundle.txt" -Recurse -Fence
```

### Running the Script

```powershell
# Execute the standalone script
.\scripts\PowerCat.ps1 -s "." -o "bundle.txt" -r -f
```

### Releasing

1. Update `ModuleVersion` in `src/PowerCat/PowerCat.psd1`
2. Update `ReleaseNotes` field in the manifest
3. Commit: `git add src/PowerCat/PowerCat.psd1 && git commit -m "Bump version to vX.Y.Z"`
4. Tag: `git tag vX.Y.Z && git push origin vX.Y.Z`
5. GitHub Actions CI/CD will test and publish to PowerShell Gallery

See `RELEASING.md` for full checklist.

## Directory Structure

```
PowerCat/
├── .github/
│   └── workflows/          # CI/CD workflows
├── scripts/
│   └── PowerCat.ps1        # Standalone script
├── src/
│   └── PowerCat/
│       ├── PowerCat.psm1   # Module implementation
│       └── PowerCat.psd1   # Module manifest
├── tests/                  # Pester test files
├── README.md               # Main documentation
├── RELEASING.md            # Release instructions
├── ReleaseNotes.md         # Version history
└── LICENSE                 # GPL v3.0
```

## Key Parameters & Aliases

| Parameter | Aliases | Purpose |
|-----------|---------|---------|
| SourceDir | s, src, source, dir | Source directory path |
| OutputFile | o, out, output, file | Output file path |
| Recurse | r, rec, recursive | Include subdirectories |
| Fence | f, fen | Wrap in Markdown fences |
| Extensions | e, ex, ext | Custom file extensions |
| Bash | b, sh | Include .sh files |
| PowerShell | p, ps, ps1 | Include .ps1 files |
| HTML | ht, htm | Include .html files |
| CSS | c, cs | Include .css files |
| Lua | l, lu | Include .lua files |
| Sort | st | Sort by Name, Extension, LastWriteTime, or Length |
| CatIgnore | ci | Path to catignore file for exclusions |
| NoCatIgnore | nci | Skip reading catignore file |

## Catignore File Format

Create a `catignore` file in the source directory to exclude files and directories from concatenation. The file format mirrors `.gitignore`:

- **Blank lines and comments:** Lines starting with `#` are ignored
- **Patterns:** Use wildcards (`*`) to match files; relative paths from the source directory
- **Examples:**
  ```
  # Ignore build directories
  bin/
  obj/
  dist/
  
  # Ignore specific file types
  *.log
  *.tmp
  
  # Ignore by name
  node_modules
  .env
  ```

You can also specify a custom path with `-CatIgnore` or skip reading the file with `-NoCatIgnore`.

## Important Notes

- Default extension is `.md` (Markdown files)
- Script execution policy: may require `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Module is published to PowerShell Gallery: https://www.powershellgallery.com/packages/PowerCat
- Repository: https://github.com/TheOnliestMattastic/PowerCat

## Contact & Links

- **Author:** Matthew Poole Chicano (TheOnliestMattastic)
- **Portfolio:** https://theonliestmattastic.github.io/
- **GitHub:** https://github.com/theonliestmattastic
- **Email:** matthew.poole485@gmail.com
