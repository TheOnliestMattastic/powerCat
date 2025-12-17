<!-- .github/copilot-instructions.md: Guidance for AI coding agents working on PowerCat -->
# PowerCat — AI Assistant Guidance

Purpose: quickly orient an AI coding agent to be productive in this repo.

- Big picture: this project ships a PowerShell module and a standalone script.
  - Module: src/PowerCat/PowerCat.psm1 (primary implementation)
  - Manifest: src/PowerCat/PowerCat.psd1
  - Script wrapper: scripts/PowerCat.ps1 (standalone usage)
  - Tests: tests/PowerCat.Tests.ps1 (Pester)
  - Docs and CI: README.md, ReleaseNotes.md, .github/workflows/pester.yml

- Key entrypoints and behavior:
  - Exported cmdlet: `Invoke-PowerCat` — the primary function to modify, test, or call.
  - Aliases: `PowerCat`, `pcat`, `concat` are set to `Invoke-PowerCat`.
  - Default file selection: `-Extensions` defaults to `.md`; switches (`-PowerShell`, `-Bash`, etc.) append extensions.
  - Header formats: `HeaderFormat` accepts `Markdown`, `JSON`, or `YAML`.
  - Sorting: `-Sort` is validated against `Name|Extension|LastWriteTime|Length`.
  - Minify: removes blank lines and lines starting with `#` or `//`.
  - Catignore: looks for a `catignore` file in `SourceDir` unless `-NoCatIgnore` is used.

- Error/IO patterns to follow when editing:
  - Use `Write-Error` / `Write-Warning` and `return` (the module follows this style).
  - Files are read/written with `-Encoding UTF8` (no BOM) for cross-platform compatibility.
  - Paths are normalized via `ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath`.

- Tests & CI:
  - Run tests locally with PowerShell/Pwsh:
    - `Import-Module .\src\PowerCat -Force; Invoke-Pester tests/PowerCat.Tests.ps1`
    - CI uses the repository `pester.yml` workflow — keep tests small and focused on public behavior.

- Common change checklist for PRs:
  - Update `src/PowerCat/PowerCat.psm1` for behavior changes; keep exported function signature stable unless intentional.
  - Add/adjust unit tests in `tests/PowerCat.Tests.ps1` to cover public surface (`Invoke-PowerCat`).
  - If public API changes, bump version in `src/PowerCat/PowerCat.psd1` and add notes to `ReleaseNotes.md`.
  - Update examples in `README.md` if CLI/aliases/parameters change.

- Quick examples for edits:
  - To add a new file-type switch (e.g., `-Toml`): extend `param` with a switch alias, append `.toml` into `$Extensions`, add README example, and add a Pester test ensuring `.toml` files are included.
  - To change minify rules: edit the `Where-Object` predicate inside the file-reading loop in `Invoke-PowerCat` and add tests for comment/blank-line behavior.

- Where to look for implementation details:
  - Core logic and filtering: src/PowerCat/PowerCat.psm1 (file enumeration, catignore parsing, binary-extension list,
    minify and fence handling, output writing).
  - Script wrapper and execution parity: scripts/PowerCat.ps1
  - Tests: tests/PowerCat.Tests.ps1