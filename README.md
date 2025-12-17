# 🐱 PowerCat

![Logo](assets/logo.png)

[![PowerCat CI](https://img.shields.io/github/actions/workflow/status/TheOnliestMattastic/PowerCat/pester.yml?branch=main&style=for-the-badge&label=CI%20Tests&labelColor=6272a4)](https://github.com/TheOnliestMattastic/PowerCat/actions/workflows/pester.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PowerCat?color=bd93f9&style=for-the-badge&labelColor=6272a4)](https://www.powershellgallery.com/packages/PowerCat)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-bd93f9?color=bd93f9&style=for-the-badge&labelColor=6272a4)](https://www.gnu.org/licenses/gpl-3.0)
[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)

## 🔭 Overview

**PowerCat** is a single-shot concatenator for bundling markdown and code into one clean text file.
It's the feline cousin of Unix `cat`—polished for PowerShell, Markdown-aware, and built for sharing code with recruiters, collaborators, and LLMs.

## ✨ Features

- **Stdout-first output:** Outputs to stdout by default (Unix `cat` style); optional file writing via `-OutputFile`.
- **Concatenation:** Bundle multiple filetypes into a single output.
- **Recursion:** Include subdirectories with `-Recurse`.
- **Token estimation:** View character and estimated token count with `-Stats` for AI context planning.
- **Markdown fences:** Opt-in code fencing with `-Fence` for clean LLM/GitHub sharing.
- **Header formats:** Choose between Markdown, JSON, or YAML with `-HeaderFormat` for flexible parsing.
- **Minification:** Strip comments and blank lines with `-Minify` for lean, token-optimized bundles.
- **Size filtering:** Exclude files by size with `-MinSize` and `-MaxSize` to control output volume.
- **Binary file detection:** Automatically skips common binary formats to prevent errors.
- **Extensions:** Default `.md` plus switches (`-Bash`, `-PowerShell`, `-HTML`, `-CSS`, `-Lua`) or custom via `-Extensions`.
- **Sorting:** Control file order with `-Sort Name|Extension|LastWriteTime|Length`.
- **Catignore support:** Exclude files and directories with a `.gitignore`-style `catignore` file.
- **Aliases:** Quick commands `PowerCat`, `pcat`, `concat` all point to `Invoke-PowerCat`.
- **Native help:** Full comment-based help via `Get-Help Invoke-PowerCat`.

## 🚀 Blasting Off

### Install from PowerShell Gallery

```powershell
Install-Module -Name PowerCat -Scope CurrentUser
Import-Module PowerCat
```

### Run as a cmdlet

```powershell
# Output to file
Invoke-PowerCat -SourceDir "C:\Project" -OutputFile "C:\bundle.txt"

# Output to stdout (and pipe to file)
Invoke-PowerCat -SourceDir "C:\Project" | Out-File "C:\bundle.txt"
```

### Aliases

```powershell
PowerCat -s . -o out.txt                    # Write to file
pcat -s . | Out-File out.txt                # Pipe to file
concat -s . -r -f -p                        # Stdout with fences
```

### Help

```powershell
Get-Help Invoke-PowerCat -Full
Get-Help Invoke-PowerCat -Examples
```

## 🧪 Examples

- **Concatenate `.md` files to stdout (default):**

```powershell
Invoke-PowerCat -s "C:\Project"
# Output streams to console; pipe to capture
Invoke-PowerCat -s "C:\Project" | Out-File bundle.txt
```

- **Bundle for LLMs with minification, fences, and token stats:**

```powershell
Invoke-PowerCat -s "C:\Project" -Recurse -Minify -Fence -PowerShell -Stats
```

Output includes:
- Stripped comments and blank lines (lean for token limits)
- Code fenced blocks (markdown-aware)
- Token estimate (4 chars/token baseline):
```
=== PowerCat Statistics ===
Files processed:     15
Total characters:    45,230
Estimated tokens:    11,308 (4 chars/token baseline)
===========================
```

- **Write to file with JSON headers for structured parsing:**

```powershell
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -Recurse -HeaderFormat JSON -Lua
```

Output includes structured headers like `{"file":"script.lua"}` for better LLM parsing.

- **Exclude large files to optimize for token limits:**

```powershell
Invoke-PowerCat -s "C:\Project" -Recurse -MaxSize 50KB -Bash
```

- **Custom extensions and sorting:**

```powershell
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -Extensions ".ps1",".json",".sh" -Sort Extension
```

- **Use catignore to exclude directories:**

Create a `catignore` file in your project:

```
node_modules/
.git/
*.log
bin/
obj/
```

Then run:

```powershell
Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -Recurse
```

- **View token estimation before bundling:**

```powershell
Invoke-PowerCat -s "C:\Project" -Recurse -Minify -Stats
# See: Files processed, Total characters, Estimated tokens
# Then decide: pipe to file, adjust MaxSize, or minify further
```

## 🗺️ Repo structure

This repo ships both a module and a standalone script for convenience:

- **Module:** `src/PowerCat/PowerCat.psm1`, `src/PowerCat/PowerCat.psd1`
- **Script:** `scripts/PowerCat.ps1`

Module usage:

```powershell
Import-Module .\src\PowerCat\ -Force
Invoke-PowerCat -s . -o out.txt
```

Script usage:

```powershell
.\scripts\PowerCat.ps1 -s . -o out.txt
```

_Note:_ If you see scripts blocked, run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` as admin or follow your org policy.

## ☄️ Why PowerCat?

Because recruiters, collaborators, and LLMs don't want a directory tree—they want one file, structured and readable.
PowerCat makes your work portable, token-efficient, and a little stylish.

### PowerCat vs. Standard `cat`

**Standard `cat` or `Get-Content`:**

```powershell
# Just dumps all files end-to-end with no structure
Get-ChildItem -Recurse -Filter "*.ps1" | Get-Content
# Output: No file separators, no headers, unclear which code belongs where
```

**PowerCat:**

```powershell
Invoke-PowerCat -s . -Recurse -Fence -PowerShell
# Output:
# --- File: script1.ps1 ---
# 
# ```ps1
# function HelloWorld { Write-Host "Hello" }
# ```
# 
# --- File: script2.ps1 ---
# 
# ```ps1
# function GoodbyeWorld { Write-Host "Goodbye" }
# ```
```

**The difference:**

| Feature | `cat` | PowerCat |
|---------|-------|----------|
| Stdout output | ✅ | ✅ (default) |
| File output (optional) | ❌ | ✅ |
| File headers | ❌ | ✅ (Markdown/JSON/YAML) |
| Code fencing | ❌ | ✅ (Markdown fences) |
| Minification | ❌ | ✅ (strip comments) |
| Token estimation | ❌ | ✅ (AI context planning) |
| Size filtering | ❌ | ✅ (min/max size) |
| Exclusion patterns | ❌ | ✅ (catignore support) |
| Sorting control | ❌ | ✅ (by name, extension, size, date) |
| Multiple extensions | ❌ | ✅ (flexible file type selection) |
| Binary safety | ❌ | ✅ (auto-skip executables, images, etc.) |

PowerCat is purpose-built for sharing code with recruiters, collaborators, and LLMs—creating readable, structured, token-aware bundles that respect context limits.

## 🛸 License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0).

## 🪐 Recruiter's note

This isn't just a script—it's a demonstration of:

- Practical PowerShell scripting and automation
- Thoughtful parameter design and UX
- Clear documentation and branding
- Cross-platform compatibility (Windows, Linux, macOS)

If you're looking for someone who blends technical depth with creative polish, you've found him.

## 👽 Contact

Curious about my projects? Want to collaborate or hire for entry-level IT/support/dev roles? Shoot me an email or connect on GitHub—I reply quickly and love new challenges.

[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)
[![Email](https://img.shields.io/badge/Email-matthew.poole485%40gmail.com-bd93f9?style=for-the-badge&logo=gmail&logoColor=white&labelColor=6272a4)](mailto:matthew.poole485@gmail.com)

> "Sometimes the questions are complicated and the answers are simple." — Dr. Seuss
