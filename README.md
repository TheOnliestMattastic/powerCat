# 🐱 powerCat

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

[![PowerCat CI](https://github.com/TheOnliestMattastic/powerCat/actions/workflows/pester.yml/badge.svg)](https://github.com/TheOnliestMattastic/powerCat/actions/workflows/pester.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/powerCat?color=bd93f9&style=for-the-badge&labelColor=6272a4)](https://www.powershellgallery.com/packages/powerCat)
[![License](https://img.shields.io/badge/License-CC0--1.0-bd93f9?style=for-the-badge&logo=creativecommons&logoColor=white&labelColor=6272a4)](https://creativecommons.org/publicdomain/zero/1.0/)
[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)

## 🔭 Overview

**powerCat** is a single‑shot concatenator for bundling markdown and code into one clean text file.  
It’s the feline cousin of `cat`—polished for PowerShell, Markdown‑aware, and built with recruiter‑friendly ergonomics.

## ✨ Features

- **Concatenation:** Bundle multiple file types into a single output file.
- **Recursion:** Include subdirectories with `-Recurse`.
- **Markdown fences:** Opt‑in code fencing with `-Fence` for clean LLM/GitHub sharing.
- **Extensions:** Default as Markdown plus switches (`-Bash`, `-PowerShell`, `-HTML`, `-CSS`) or custom list via `-Extensions`.
- **Sorting:** Control order with `-Sort Name|Extension|LastWriteTime|Length`.
- **Aliases:** Quick commands `powerCat`, `pcat`, `concat` point to `Invoke-PowerCat`.
- **Native help:** Rich comment‑based help available via `Get-Help Invoke-PowerCat`.

## 🚀 Blasting Off

### Install from PowerShell Gallery

```powershell
Install-Module -Name powerCat -Scope CurrentUser
Import-Module powerCat
```

### Run as a cmdlet

```powershell
Invoke-PowerCat -SourceDir "C:\Project" -OutputFile "C:\bundle.txt"
```

### Aliases

```powershell
powerCat -s . -o out.txt
pcat -s . -o out.txt -r -f
concat -s . -o out.txt -b -p -Sort Extension
```

### Help

```powershell
Get-Help Invoke-PowerCat -Full
Get-Help Invoke-PowerCat -Examples
Invoke-PowerCat -Help
```

## 🧪 Examples

- **Concatenate `.md` files (default):**

  ```powershell
  Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt"
  ```

- **Recurse and wrap each file in fenced blocks:**

  ```powershell
  Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -Recurse -Fence
  ```

- **Add Bash and PowerShell files, sorted by extension:**

  ```powershell
  Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -Bash -PowerShell -Sort Extension
  ```

- **Custom extensions:**

  ```powershell
  Invoke-PowerCat -s "C:\Project" -o "C:\bundle.txt" -Extensions ".ps1",".json",".sh"
  ```

## 🗺️ Repo structure

This repo ships both a module and a standalone script for convenience:

- **Module:** `src/powerCat.psm1`, `src/powerCat.psd1`
- **Script:** `scripts/powerCat.ps1`

Module usage:

```powershell
Import-Module .\src\powerCat.psd1 -Force
Invoke-PowerCat -s . -o out.txt
```

Script usage:

```powershell
.\scripts\powerCat.ps1 -s . -o out.txt
```

_Note:_ If you see scripts blocked, run `Set-ExcecutionPolicy RemoteSigned -Scope CurrentUser` as admin or follow your org policy.

## ☄️ Why powerCat?

Because recruiters, collaborators, and LLMs don’t want a directory tree—they want one file.  
powerCat makes your work readable, portable, and a little stylish.

## 🛸 License

This project is licensed under the [CC0‑1.0 Universal License](https://creativecommons.org/publicdomain/zero/1.0/).

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
