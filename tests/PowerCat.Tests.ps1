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
                $result | Should -Match "No matching"
            }
            finally {
                Remove-Item -Path $tempDir -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context "When files exist" {
        BeforeAll {
            $tempDir = Join-Path /tmp "PowerCatTest_$([System.Guid]::NewGuid())"
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

        It "Concatenates .md files by default" {
            $outFile = Join-Path /tmp "bundle_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile

                $content = Get-Content $outFile -Raw
                $content | Should -Match "Hello"
                $content | Should -Match "World"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Uses Markdown headers by default" {
            $outFile = Join-Path /tmp "markdown_$([System.Guid]::NewGuid()).txt"
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
            $tempDir = Join-Path /tmp "PowerCatHeaderTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.md") -Value "Content"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Generates JSON headers with -hf JSON" {
            $outFile = Join-Path /tmp "json_$([System.Guid]::NewGuid()).txt"
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
            $outFile = Join-Path /tmp "yaml_$([System.Guid]::NewGuid()).txt"
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
            $outFile = Join-Path /tmp "alias_$([System.Guid]::NewGuid()).txt"
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
            $tempDir = Join-Path /tmp "PowerCatMinifyTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.ps1") -Value @"
# Comment line 1
function HelloWorld {
    # Comment inside function
    Write-Host "Hello"
}

# Comment line 2
"@
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Removes comments and blank lines with -Minify" {
            $outFile = Join-Path /tmp "minify_$([System.Guid]::NewGuid()).txt"
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
            $outFile = Join-Path /tmp "minify_alias_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".ps1" -mini
                
                $content = Get-Content $outFile
                $content | Should -Not -Match "# Comment"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Works with custom headers" {
            $outFile = Join-Path /tmp "minify_json_$([System.Guid]::NewGuid()).txt"
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
            $tempDir = Join-Path /tmp "PowerCatSizeTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "small.md") -Value "S"       # 1 byte
            Set-Content -Path (Join-Path $tempDir "large.md") -Value ("X" * 1000)  # 1000 bytes
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Excludes files smaller than MinSize" {
            $outFile = Join-Path /tmp "minsize_$([System.Guid]::NewGuid()).txt"
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
            $outFile = Join-Path /tmp "maxsize_$([System.Guid]::NewGuid()).txt"
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
            $tempDir = Join-Path /tmp "PowerCatBinaryTest_$([System.Guid]::NewGuid())"
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
            $outFile = Join-Path /tmp "binary_skip_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -Recurse
                
                $content = Get-Content $outFile -Raw
                $content | Should -Match "Text file"
                # Should not contain binary file indicators or errors
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
                
                Invoke-PowerCat -s $sourceDir -o $outFile 2>&1 | Out-Null
                
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
            $tempDir = Join-Path /tmp "PowerCatStdoutTest_$([System.Guid]::NewGuid())"
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
            $outFile = Join-Path /tmp "pipe_redirect_$([System.Guid]::NewGuid()).txt"
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
            $tempDir = Join-Path /tmp "PowerCatFileOutputTest_$([System.Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "test.md") -Value "Test Content"
        }

        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Returns FileInfo object when OutputFile specified" {
            $outFile = Join-Path /tmp "pipe_output_$([System.Guid]::NewGuid()).txt"
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
            $outFile = Join-Path /tmp "pipe_chain_$([System.Guid]::NewGuid()).txt"
            try {
                Invoke-PowerCat -s $tempDir -o $outFile -e ".md" | Get-Content -Raw | Should -Match "Test Content"
            }
            finally {
                Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
            }
        }

        It "Accepts pipeline input from string path with OutputFile" {
            $outFile = Join-Path /tmp "pipe_string_$([System.Guid]::NewGuid()).txt"
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
            $outFile = Join-Path /tmp "pipe_obj_$([System.Guid]::NewGuid()).txt"
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
}
