# Requires -Version 5.0
Import-Module "$PSScriptRoot\..\src\powerCat\powerCat.psd1" -Force

Describe "powerCat Module" {

    It "Exports the Invoke-PowerCat function" {
        Get-Command Invoke-PowerCat -Module powerCat | Should -Not -BeNullOrEmpty
    }

    It "Exports expected aliases" {
        (Get-Alias powerCat).Definition | Should -Be "Invoke-PowerCat"
        (Get-Alias pcat).Definition     | Should -Be "Invoke-PowerCat"
        (Get-Alias concat).Definition   | Should -Be "Invoke-PowerCat"
    }

    It "Shows help with -h flag" {
        $result = Invoke-PowerCat -h
        $result | Should -Match "USAGE"
    }

    Context "When no files match" {
        It "Returns gracefully with no crash" {
            $tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "EmptyTest") -Force
            $result = Invoke-PowerCat -s $tempDir.FullName -o "$env:TEMP\out.txt"
            $result | Should -Match "No matching files"
        }
    }

    Context "When files exist" {
        It "Concatenates .md files by default" {
            $tempDir = Join-Path $env:TEMP "PowerCatTest"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Set-Content -Path (Join-Path $tempDir "a.md") -Value "Hello"
            Set-Content -Path (Join-Path $tempDir "b.md") -Value "World"

            $outFile = Join-Path $env:TEMP "bundle.txt"
            Invoke-PowerCat -s $tempDir -o $outFile

            $content = Get-Content $outFile -Raw
            $content | Should -Match "Hello"
            $content | Should -Match "World"
        }
    }
}
