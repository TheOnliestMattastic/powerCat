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

<!-- [![PowerShell Gallery](https://img.shields.io/powershellgallery/v/powerCat?color=bd93f9&style=for-the-badge&labelColor=6272a4)](https://www.powershellgallery.com/packages/powerCat)  -->
[![License](https://img.shields.io/badge/License-CC0--1.0-bd93f9?style=for-the-badge&logo=creativecommons&logoColor=white&labelColor=6272a4)](https://creativecommons.org/publicdomain/zero/1.0/)
[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)  

## 🔭 Overview

**powerCat** is a single‑shot concatenator for bundling code and docs into one clean text file.  
Think of it as the feline cousin of `cat`—but with PowerShell polish, and Markdown‑aware formatting.

## ☄️ Features

- Concatenate multiple file types into one output file
- Supports recursion into subdirectories (`-r`)
- Optional Markdown code fencing (`-f`) for LLMs, GitHub, or recruiters
- Flexible extension handling (`-e ".ps1",".json"`) plus quick switches (`-b` for Bash, `-p` for PowerShell, etc.)
- Sorting control (`-sort Name|Extension|LastWriteTime|Length`)
- Built‑in help (`-h`) with usage examples

## 🚀 Getting Started

### Install from PowerShell Gallery

```powershell
Install-Module -Name powerCat -Scope CurrentUser
Import-Module powerCat
```

### Import as a Module

```powershell
Import-Module .\src\powerCat.psd1 -Force
Invoke-PowerCat -s "C:\path\to\dir" -o "C:\path\to\file.txt"
```

### Run as a Script

```powershell
.\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt"
```

### Examples

- Concatenate `.lua` and `.md` files:

  ```powershell
  .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt"
  ```

- Include subdirectories and wrap in Markdown:

  ```powershell
  .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -r -f
  ```

- Add Bash and PowerShell files, sorted by extension:

  ```powershell
  .\powerCat.ps1 -s "C:\Project" -o "C:\bundle.txt" -b -p -sort Extension
  ```

## 📡 Why?

Because recruiters, collaborators, and LLMs don’t want a folder tree—they want one file.  
**powerCat** makes it painless to share your work in a way that’s readable, portable, and a little bit stylish.

## 🛸 License

This project is licensed under the [CC0‑1.0 Universal License](https://creativecommons.org/publicdomain/zero/1.0/).

## 👽 Contact

[![Portfolio](https://img.shields.io/badge/Portfolio-bd93f9?style=for-the-badge&logo=githubpages&logoColor=white&labelColor=6272a4)](https://theonliestmattastic.github.io/)  
[![GitHub](https://img.shields.io/badge/GitHub-Profile-bd93f9?style=for-the-badge&logo=github&logoColor=white&labelColor=6272a4)](https://github.com/theonliestmattastic)  
[![Email](https://img.shields.io/badge/Email-matthew.poole485%40gmail.com-bd93f9?style=for-the-badge&logo=gmail&logoColor=white&labelColor=6272a4)](mailto:matthew.poole485@gmail.com)  

> _“Sometimes the questions are complicated and the answers are simple.”_ — Dr. Seuss
