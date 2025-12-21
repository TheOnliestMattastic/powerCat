# Requires -Version 5.0
$ModulePath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "src/PowerCat/PowerCat.psd1"
Import-Module $ModulePath -Force

Describe "PowerCat Module" {

    It "Exports the Invoke-PowerCat function" {
        Get-Command Invoke-PowerCat -Module PowerCat | Should -Not -BeNullOrEmpty
    }

    It "Exports expected aliases" {
        (Get-Alias PowerCat).Definition | Should -Be "Invoke-PowerCat"
        (Get-Alias pcat).Definition     | Should -Be "Invoke-PowerCat"
        (Get-Alias concat).Definition   | Should -Be "Invoke-PowerCat"
    }

    Context "When no files match" {
        It "Returns gracefully with stdout message" {
            $tempDir = New-Item -ItemType Directory -Path "/tmp/EmptyTest_$([System.Guid]::NewGuid())" -Force
            try {
                $result = Invoke-PowerCat -s $tempDir.FullName 2>&1 | Out-String
                $result | Should -Match "No extensions selected"
            }
            finally {
                Remove-Item -Path $tempDir -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Defaults and positional parameters" {
        It "Does not include Markdown files by default" {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatMdDefault_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "only.md") -Value "Hidden"
            try {
                $result = Invoke-PowerCat -s $tempDir 2>&1 | Out-String
                $result | Should -Match "No extensions selected"
            }
            finally {
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Includes Markdown when -IncludeMarkdown is used" {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatMdInclude_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "only.md") -Value "Visible"
            try {
                $result = Invoke-PowerCat -s $tempDir -IncludeMarkdown 2>&1 | Out-String
                $result | Should -Match "Visible"
            }
            finally {
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Accepts positional SourceDir parameter" {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatPositional_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "a.md") -Value "Positional"
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "positional_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat $tempDir -IncludeMarkdown -o $outFile
                $content = Get-Content $outFile -Raw
                $content | Should -Match "Positional"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "When files exist" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "a.md") -Value "Hello"
            Set-Content -Path (Join-Path $tempDir "b.md") -Value "World"
            # Create test files with comments for minification tests
            Set-Content -Path (Join-Path $tempDir "test.ps1") -Value @"
# This is a comment
function HelloWorld {
    Write-Host "Hello"
}

# End
"@
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Includes Markdown files when requested" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "bundle_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -IncludeMarkdown

                $content = Get-Content $outFile -Raw
                $content | Should -Match "Hello"
                $content | Should -Match "World"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Uses Markdown headers by default" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "markdown_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md"
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "--- File: a.md ---"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "HeaderFormat parameter" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatHeaderTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.md") -Value "Content"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Generates JSON headers with -hf JSON" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "json_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" -hf JSON
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match '\{"file":"test\.md"\}'
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Generates YAML headers with -hf YAML" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "yaml_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" -hf YAML
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "file: test\.md"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Accepts alias -hf for -HeaderFormat" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "alias_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" -hf JSON
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match '\{"file":"test\.md"\}'
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Minify parameter" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatMinifyTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.ps1") -Value @"
# Comment line 1
function HelloWorld {
    # Comment inside function
    Write-Host "Hello"
    // js-style comment
}

# Comment line 2
"@
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Removes comments and blank lines with -Minify" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "minify_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".ps1" -Minify
                
                $content = Get-Content $outFile -Raw
                $content | Should -Not -Match "# Comment"
                $content | Should -Match "function HelloWorld"
                $content | Should -Match 'Write-Host "Hello"'
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Accepts alias -mini for -Minify" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "minify_alias_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".ps1" -mini
                
                $content = Get-Content $outFile
                $content | Should -Not -Match "# Comment"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Removes '//' style comments when Minify is enabled" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "minify_slash_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".ps1" -Minify
                
                $content = Get-Content $outFile -Raw
                $content | Should -Not -Match "^//"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Works with custom headers" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "minify_json_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".ps1" -Minify -hf JSON
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match '\{"file":"test\.ps1"\}'
                $content | Should -Not -Match "# Comment"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Size filtering" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatSizeTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "small.md") -Value "S"       # 1 byte
            Set-Content -Path (Join-Path $tempDir "large.md") -Value ("X" * 1000)  # 1000 bytes
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Excludes files smaller than MinSize" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "minsize_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" -MinSize 100
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "X{1000}"
                $content | Should -Not -Match "^S$"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Excludes files larger than MaxSize" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "maxsize_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" -MaxSize 100
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "S"
                $content | Should -Not -Match "X{1000}"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Binary file detection" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatBinaryTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "text.md") -Value "Text file"
            # Create mock binary files with extensions that should be skipped
            [System.IO.File]::WriteAllBytes((Join-Path $tempDir "binary.exe"), @(0x4D, 0x5A))
            [System.IO.File]::WriteAllBytes((Join-Path $tempDir "binary.dll"), @(0x4D, 0x5A))
            [System.IO.File]::WriteAllBytes((Join-Path $tempDir "image.png"), @(0x89, 0x50, 0x4E, 0x47))
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Skips binary files (.exe, .dll, image formats)" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "binary_skip_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -Recurse -IncludeMarkdown
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "Text file"
                { $content | Should -Not -Match "Cannot process binary file" } | Should -Not -Throw
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Output directory validation" {
        It "Successfully creates output file in valid directory" {
            $baseTempDir = [System.IO.Path]::GetTempPath()
            $sourceDir = Join-Path $baseTempDir "PowerCatSource_$([System.Guid]::NewGuid())"
            $outputDir = Join-Path $baseTempDir "PowerCatOutput_$([System.Guid]::NewGuid())"
            $outFile = Join-Path $outputDir "output.txt"
            
            try {
                New-Item -ItemType Directory -Path $sourceDir -Force | Out-Null
                New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
                Set-Content -Path (Join-Path $sourceDir "test.md") -Value "Test content"
                
                Invoke-PowerCat -s $sourceDir -o $outFile -IncludeMarkdown 2>&1 | Out-Null
                
                Test-Path $outFile | Should -Be $true
            }
            finally {
                Remove-Item -Path $sourceDir -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $outputDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Stdout output (no OutputFile)" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatStdoutTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.md") -Value "Test Content"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Outputs to stdout when no OutputFile specified" {
            $result = Invoke-PowerCat -s $tempDir -e ".md" 2>&1 | Out-String
            $result | Should -Match "Test Content"
            $result | Should -Match "--- File: test\.md ---"
        }

        It "Accepts pipeline input from string path and outputs to stdout" {
            $result = $tempDir | Invoke-PowerCat -e ".md" 2>&1 | Out-String
            $result | Should -Match "Test Content"
        }

        It "Accepts pipeline input from directory object and outputs to stdout" {
            $dirObj = Get-Item $tempDir
            $result = $dirObj | Invoke-PowerCat -e ".md" 2>&1 | Out-String
            $result | Should -Match "Test Content"
        }

        It "Can pipe stdout to Out-File for redirection" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "pipe_redirect_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -e ".md" 2>&1 | Out-File -Path $outFile -Encoding UTF8
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "Test Content"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "File output (with OutputFile)" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatFileOutputTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.md") -Value "Test Content"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Returns FileInfo object when OutputFile specified" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "pipe_output_$([System.Guid]::NewGuid()).txt"
            try {
                $result = Invoke-PowerCat -s $tempDir -o $outFile -e ".md" 2>&1 | Where-Object { $_ -is [System.IO.FileInfo] }
                $result | Should -Not -BeNullOrEmpty
                $result | Get-Member | Where-Object Name -eq "FullName" | Should -Not -BeNullOrEmpty
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Supports pipeline chaining with Get-Content" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "pipe_chain_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" | Get-Content -Raw | Should -Match "Test Content"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Accepts pipeline input from string path with OutputFile" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "pipe_string_$([System.Guid]::NewGuid()).txt"
            try {
                $result = $tempDir | Invoke-PowerCat -o $outFile -e ".md" 2>&1 | Where-Object { $_ -is [System.IO.FileInfo] }
                $result | Should -Not -BeNullOrEmpty
                $result.Name | Should -Match "pipe_string"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Accepts pipeline input from directory object with OutputFile" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "pipe_obj_$([System.Guid]::NewGuid()).txt"
            try {
                $dirObj = Get-Item $tempDir
                $result = $dirObj | Invoke-PowerCat -o $outFile -e ".md" 2>&1 | Where-Object { $_ -is [System.IO.FileInfo] }
                $result | Should -Not -BeNullOrEmpty
                $result.Name | Should -Match "pipe_obj"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Additional behaviors" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatExtraTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "code.ps1") -Value "Write-Host 'X'"
            Set-Content -Path (Join-Path $tempDir "included.md") -Value "Included"
            Set-Content -Path (Join-Path $tempDir "secret.md") -Value "Secret"
            # catignore will exclude secret.md
            Set-Content -Path (Join-Path $tempDir "catignore") -Value "secret.md"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Wraps content in fences with -Fence" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "fence_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".ps1" -f
                $content = Get-Content $outFile -Raw
                $content | Should -Match "```ps1"
                $content | Should -Match "```\s*$"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Respects catignore by default" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "catignore_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -Recurse -IncludeMarkdown
                $content = Get-Content $outFile -Raw
                $content | Should -Match "Included"
                $content | Should -Not -Match "Secret"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Skips catignore when -NoCatIgnore is used" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "nocatignore_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -Recurse -nci -IncludeMarkdown
                $content = Get-Content $outFile -Raw
                $content | Should -Match "Included"
                $content | Should -Match "Secret"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Statistics reporting" {
        BeforeAll {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatStatsTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test1.md") -Value "Hello"
            Set-Content -Path (Join-Path $tempDir "test2.md") -Value "World"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Displays file count in stats output" {
            $result = Invoke-PowerCat -s $tempDir -sta -IncludeMarkdown 2>&1 | Out-String
            $result | Should -Match "Files processed"
            $result | Should -Match "\b2\b"
        }

        It "Displays character count in stats output" {
            $result = Invoke-PowerCat -s $tempDir -sta -IncludeMarkdown 2>&1 | Out-String
            $result | Should -Match "Total characters"
        }

        It "Displays token estimation in stats output" {
            $result = Invoke-PowerCat -s $tempDir -sta -IncludeMarkdown 2>&1 | Out-String
            $result | Should -Match "Estimated tokens"
            $result | Should -Match "4 chars/token"
        }

        It "Stats work with file output (-o flag)" {
            $outFile = Join-Path ([System.IO.Path]::GetTempPath()) "stats_file_$([System.Guid]::NewGuid()).txt"
            try {
                $result = Invoke-PowerCat -s $tempDir -o $outFile -sta -IncludeMarkdown 2>&1 | Out-String
                $result | Should -Match "Files processed"
                $result | Should -Match "Total characters"
                
                Test-Path $outFile | Should -Be $true
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Stats work with stdout (no -o flag)" {
            $result = Invoke-PowerCat -s $tempDir -sta -IncludeMarkdown 2>&1 | Out-String
            $result | Should -Match "PowerCat Statistics"
            $result | Should -Match "Hello|World"
        }

        It "Token count is ceiling of characters divided by 4" {
            $testDir = Join-Path ([System.IO.Path]::GetTempPath()) "PowerCatTokenTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            try {
                Set-Content -Path (Join-Path $testDir "exact.md") -Value "0123456789"
                
                $result = Invoke-PowerCat -s $testDir -e ".md" -sta 2>&1 | Out-String
                $result | Should -Match "Estimated tokens:\s+\d+"
            }
            finally {
                Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "Error handling and Help" {
        It "Errors when SourceDir does not exist" {
            $tempPath = [System.IO.Path]::GetTempPath()
            $nonexistent = Join-Path $tempPath "NoSuchDir_$([System.Guid]::NewGuid())"
            { Invoke-PowerCat -s $nonexistent -ErrorAction Stop } | Should -Throw
        }

        It "Errors when output directory does not exist" {
            $tempPath = [System.IO.Path]::GetTempPath()
            $src = Join-Path $tempPath "PowerCatHelpSrc_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $src -Force | Out-Null
            $badOut = Join-Path $tempPath "NoSuchOutDir_$([System.Guid]::NewGuid())" "out.txt"
            try {
                { Invoke-PowerCat -s $src -o $badOut -ErrorAction Stop } | Should -Throw
            }
            finally {
                Remove-Item -Path $src -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Errors when output path parent exists but is a file (not a directory)" {
            $tempPath = [System.IO.Path]::GetTempPath()
            $src = Join-Path $tempPath "PowerCatHelpSrc2_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $src -Force | Out-Null

            $fileAsDir = Join-Path $tempPath "fileAsDir_$([System.Guid]::NewGuid())"
            Set-Content -Path $fileAsDir -Value "I am a file"
            $outPath = Join-Path $fileAsDir "child.txt"  # parent is a file, not a directory

            try {
                { Invoke-PowerCat -s $src -o $outPath -ErrorAction Stop } | Should -Throw
            }
            finally {
                Remove-Item -Path $src -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $fileAsDir -Force -ErrorAction SilentlyContinue
            }
        }
    }
}