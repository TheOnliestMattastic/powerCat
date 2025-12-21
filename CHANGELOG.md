# Changelog

All notable changes to POWERcat are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-21

### ⚠️ Breaking

- Removed implicit inclusion of `.md` files. Users must explicitly opt-in with `-IncludeMarkdown` or `-Extensions ".md"`.

### ✨ Added

- `-IncludeMarkdown` switch to explicitly include Markdown files.
- `-ExcludeExtensions` to remove selected extension types from processing.
- `-ForceOverwrite` to remove and overwrite existing read-only output files when requested.
- Comma-separated `-Extensions` parsing for convenience (e.g. `-Extensions ".ps1,.md"`).

### ✅ Improved

- Positional `SourceDir` clarified as the first required parameter.
- Script wrapper (`scripts/POWERcat.ps1`) now mirrors module behavior and accepts the same flags.
- Expanded Pester tests to cover new behaviors and script parity.

### 🧭 Migration

- Update automation to include `-IncludeMarkdown` or explicit `-Extensions` if you previously relied on implicit Markdown inclusion.

## [1.1.0] - 2025-12-18

### ✨ Added

- **Stdout-first output** — Default output to console (Unix `cat` style); optional file writing via `-OutputFile`
- **Recursive bundling** — Include subdirectories with `-Recurse` for comprehensive project bundling
- **Token estimation** — View character and estimated token count with `-Stats` for AI context planning
- **Markdown code fencing** — Opt-in code fencing with `-Fence` for clean LLM/GitHub sharing
- **Header format options** — Choose between Markdown, JSON, or YAML with `-HeaderFormat` for flexible parsing
- **Minification support** — Strip comments and blank lines with `-Minify` for lean, token-optimized bundles
- **Size filtering** — Exclude files by size with `-MinSize` and `-MaxSize` to control output volume
- **Binary file detection** — Automatically skips common binary formats (images, executables, archives)
- **Extension filters** — Default `.md` plus switches (`-Bash`, `-PowerShell`, `-HTML`, `-CSS`, `-Lua`) or custom via `-Extensions`
- **Sorting options** — Control file order with `-Sort Name|Extension|LastWriteTime|Length`
- **Catignore support** — Exclude files and directories with a `.gitignore`-style `catignore` file
- **Command aliases** — Quick commands `POWERcat`, `pcat`, `concat` all point to `Invoke-POWERcat`
- **Native help system** — Full comment-based help via `Get-Help Invoke-POWERcat`
- **Cross-platform support** — Windows, Linux (via PowerShell Core), macOS

### 🛠️ Infrastructure

- **PowerShell Gallery** — Published as official module for easy installation
- **CI/CD pipeline** — GitHub Actions workflow for Pester testing on every push
- **Module structure** — Professional PSM1/PSD1 format for distribution
- **Standalone script** — Alternative script-based usage without module installation

### 📚 Documentation

- **Comprehensive README** — Overview, features, examples, and use cases
- **Native PowerShell help** — Full documentation via `Get-Help` cmdlet
- **Usage examples** — Real-world scenarios for bundling, LLM sharing, and token estimation
- **Feature comparison table** — POWERcat vs. standard `cat`/`Get-Content` for clear value proposition

### 🎯 Features for AI & LLMs

- **Token estimation** — Character count and estimated token usage (4 chars/token baseline)
- **Minification** — Optimized output for token-limited AI requests
- **Markdown fencing** — Clean code blocks for AI parsing and GitHub markdown
- **Header formats** — Structured headers (Markdown/JSON/YAML) for programmatic parsing
- **Size controls** — Fine-tune output to stay within AI context windows

### 🔄 Code Quality

- **Modular design** — Clean, maintainable PowerShell code
- **Error handling** — Graceful handling of missing files and invalid paths
- **Performance** — Optimized for large directories and recursive bundling
- **Accessibility** — Clear, beginner-friendly command syntax and documentation

## [1.0.0] - 2025-01-15

### ✨ Initial Release

- **Core functionality** — Concatenate files into single output
- **Basic filtering** — File extensions and recursive directory support
- **Output options** — Stdout and file writing
- **Help documentation** — PowerShell comment-based help

---

## Future Roadmap

- [ ] **Batch operations** — Process multiple source directories in one command
- [ ] **Custom separators** — User-defined file delimiters
- [ ] **Preview mode** — Show what would be concatenated without bundling
- [ ] **Parallel processing** — Faster bundling for large projects
- [ ] **Cloud integration** — Direct upload to cloud storage or AI services
- [ ] **GUI application** — Windows/cross-platform graphical interface
