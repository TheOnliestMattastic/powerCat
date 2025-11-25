# 🐱 POWERcat

![Logo](assets/logo.png)

[![POWERcat CI](https://img.shields.io/github/actions/workflow/status/TheOnliestMattastic/PowerCat/pester.yml?branch=main&style=for-the-badge&label=CI%20Tests&labelColor=6272a4)](https://github.com/TheOnliestMattastic/PowerCat/actions/workflows/pester.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PowerCat?color=bd93f9&style=for-the-badge&labelColor=6272a4)](https://www.powershellgallery.com/packages/PowerCat)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-bd93f9?color=bd93f9&style=for-the-badge&labelColor=6272a4)](https://www.gnu.org/licenses/gpl-3.0)
[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)

## 🔭 Overview

**POWERcat** is a single‑shot concatenator for bundling markdown and code into one clean text file.  
It’s the feline cousin of `cat`—polished for PowerShell, Markdown‑aware, and built with recruiter‑friendly ergonomics.

## ✨ Features

- **Concatenation:** Bundle multiple filetypes into a single output file.
- **Recursion:** Include subdirectories with `-Recurse`.
- **Markdown fences:** Opt‑in code fencing with `-Fence` for clean LLM/GitHub sharing.
- **Header formats:** Choose between Markdown, JSON, or YAML headers with `-HeaderFormat` for flexible LLM integration.
- **Minification:** Strip comments and blank lines with `-Minify` for lean, LLM‑optimized bundles.
- **Size filtering:** Exclude files by size with `-MinSize` and `-MaxSize` to control output volume.
- **Binary file detection:** Automatically skips common binary formats to prevent concatenation errors.
- **Extensions:** Default as Markdown plus switches (`-Bash`, `-PowerShell`, `-HTML`, `-CSS`) or custom list via `-Extensions`.
- **Sorting:** Control order with `-Sort Name|Extension|LastWriteTime|Length`.
- **Catignore support:** Exclude files and directories with a `.gitignore`‑style `catignore` file.
- **Aliases:** Quick commands `PowerCat`, `pcat`, `concat` point to `Invoke-PowerCat`.
- **Native help:** Rich comment‑based help available via `Get-Help Invoke-PowerCat` (or `-Help` in the standalone script for bash/macOS users seeking Unix-style man-page ergonomics).

## 🚀 Blasting Off

### Install from PowerShell Gallery

```powershell
Install-Module -Name POWERcat -Scope CurrentUser
Import-Module PowerCat
```

### Run as a cmdlet

```powershell
Invoke-POWERcat -SourceDir "C:\Project" -OutputFile "C:\bundle.txt"
```

### Aliases

```powershell
POWERcat -s . -o out.txt
pcat -s . -o out.txt -r -f
concat -s . -o out.txt -b -p -Sort Extension
```

### Help

```powershell
Get-Help Invoke-POWERcat -Full
Get-Help Invoke-POWERcat -Examples
Invoke-POWERcat -Help
```

## 🧪 Examples

- **Concatenate `.md` files (default):**

```powershell
Invoke-POWERcat -s "C:\Project" -o "C:\bundle.txt"
```

- **Bundle for LLMs with minification and fenced code:**

```powershell
Invoke-POWERcat -s "C:\Project" -o "C:\bundle.txt" -Recurse -Minify -Fence -PowerShell
```

This strips comments and blank lines, making the bundle lean and optimized for token limits.

- **Generate JSON headers for structured LLM parsing:**

```powershell
Invoke-POWERcat -s "C:\Project" -o "C:\bundle.txt" -Recurse -HeaderFormat JSON -Lua
```

Output includes structured headers like `{"file":"script.ps1"}` for better LLM integration.

- **Exclude large files to optimize for token limits:**

```powershell
Invoke-POWERcat -s "C:\Project" -o "C:\bundle.txt" -Recurse -MaxSize 50KB -Bash
```

- **Custom extensions and sorting:**

```powershell
Invoke-POWERcat -s "C:\Project" -o "C:\bundle.txt" -Extensions ".ps1",".json",".sh" -Sort Extension
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
Invoke-POWERcat -s "C:\Project" -o "C:\bundle.txt" -Recurse -PowerShell
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

## ☄️ Why POWERcat?

Because recruiters, collaborators, and LLMs don't want a directory tree—they want one file structured and readable.  
PowerCat makes your work portable, token-efficient, and a little stylish.

### POWERcat vs. Standard `cat`

**Standard `cat` or `Get-Content`:**

```powershell
# Just dumps all files end-to-end with no structure
Get-ChildItem -Recurse -Filter "*.ps1" | Get-Content
# Output: No file separators, no headers, unclear which code belongs where
```

**POWERcat:**

```powershell
Invoke-POWERcat -s . -o bundle.txt -Recurse -Fence -PowerShell
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
| File headers | ❌ | ✅ (Markdown/JSON/YAML) |
| Code fencing | ❌ | ✅ (Markdown fences) |
| Minification | ❌ | ✅ (strip comments) |
| Size filtering | ❌ | ✅ (min/max size) |
| Exclusion patterns | ❌ | ✅ (catignore support) |
| LLM optimization | ❌ | ✅ (token-aware) |
| Sorting control | ❌ | ✅ (by name, extension, size, date) |
| Multiple extensions | ❌ | ✅ (flexible file type selection) |

POWERcat is purpose-built for sharing code with recruiters, collaborators, and LLMs—creating readable, structured, LLM-optimized bundles that respect token limits.

## 🛸 License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0).

## 🪐 Recruiter’s note

This isn’t just a script—it’s a demonstration of:

- Practical PowerShell scripting and automation
- Thoughtful parameter design and UX
- Clear documentation and branding

If you’re looking for someone who blends technical depth with creative polish, you’ve found him.

## 👽 Contact

Curious about my projects? Want to collaborate or hire for entry-level IT/support/dev roles? Shoot me an email or connect on GitHub—I reply quickly and love new challenges.

[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)  
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)  
[![Email](https://img.shields.io/badge/Email-matthew.poole485%40gmail.com-bd93f9?style=for-the-badge&logo=gmail&logoColor=white&labelColor=6272a4)](mailto:matthew.poole485@gmail.com)

> “Sometimes the questions are complicated and the answers are simple.” — Dr. Seuss
