#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Ignite - Personal Project Scaffolder v5.
.DESCRIPTION
    Usage:
      ignite list
      ignite update
      ignite MyProject -Type Python
      ignite QuickScript -Simple -NoCode
#>
param(
    [string]$ProjectName,
    [string]$Destination = ".",
    [ValidateSet("Python", "PowerShell", "Web", "Go", "Terraform", "Docker", "Empty")]
    [string]$Type,
    [switch]$Simple,  # Quick Mode
    [switch]$NoCode   # Prevents VS Code from opening
)

# --- Feature: Self-Update ---
if ($ProjectName -eq "update") {
    Write-Host "🚀 Updating Ignite..." -ForegroundColor Cyan
    
    # Get the directory where THIS script lives
    $ScriptHome = $PSScriptRoot
    
    if (-not (Test-Path "$ScriptHome/.git")) {
        Write-Error "This script is not inside a Git repository. Cannot auto-update."
        Write-Host "Location: $ScriptHome" -ForegroundColor Gray
        exit 1
    }

    Set-Location $ScriptHome
    try {
        git pull
        Write-Host "Update check complete." -ForegroundColor Green
    } catch {
        Write-Error "Failed to update. Check your git remote configuration."
    }
    exit 0
}

# --- Feature: Help / List ---
if ($ProjectName -in "list", "help", "?", "-?", "/?") {
    Write-Host "🔥 IGNITE - Project Scaffolder v5" -ForegroundColor Red
    Write-Host "--------------------------------" -ForegroundColor Gray
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  ignite update               " -NoNewline; Write-Host "(Self-update from Git)" -ForegroundColor DarkGray
    Write-Host "  ignite <Name>               " -NoNewline; Write-Host "(Interactive Menu)" -ForegroundColor DarkGray
    Write-Host "  ignite <Name> -Simple       " -NoNewline; Write-Host "(Quick Python Script)" -ForegroundColor DarkGray
    Write-Host "  ignite <Name> -NoCode       " -NoNewline; Write-Host "(Don't open VS Code)" -ForegroundColor DarkGray
    exit 0
}

# --- Interactive Menu ---
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Read-Host "Enter Project Name"
}

# Default to Python if Simple is used
if ($Simple -and [string]::IsNullOrWhiteSpace($Type)) {
    $Type = "Python"
}

if ([string]::IsNullOrWhiteSpace($Type)) {
    Write-Host "`nSelect Project Type:" -ForegroundColor Cyan
    Write-Host "1. Python (Quick)"
    Write-Host "2. Python (Full)"
    Write-Host "3. PowerShell"
    Write-Host "4. Terraform"
    Write-Host "5. Docker"
    Write-Host "6. Go"
    Write-Host "7. Web"
    
    $selection = Read-Host "Choice (1-7)"
    
    if ($selection -eq "1") {
        $Type = "Python"
        $Simple = $true
    } else {
        $Type = switch ($selection) {
            "2" { "Python" }
            "3" { "PowerShell" }
            "4" { "Terraform" }
            "5" { "Docker" }
            "6" { "Go" }
            "7" { "Web" }
            Default { "Empty" }
        }
    }
}

# --- Setup Paths ---
$ResolvedDest = Resolve-Path $Destination -ErrorAction SilentlyContinue
if (-not $ResolvedDest) { $ResolvedDest = $Destination }
$FullPath = Join-Path $ResolvedDest $ProjectName

if (Test-Path $FullPath) {
    Write-Error "Directory '$FullPath' already exists!"
    exit 1
}

Write-Host "`nIgniting '$ProjectName' as [$Type]..." -ForegroundColor Red
if ($Simple) { Write-Host "(Mode: Simple/Quick)" -ForegroundColor Yellow }

# 1. Create Root & Git Init
New-Item -Path $FullPath -ItemType Directory | Out-Null
Set-Location $FullPath
Write-Host "Initializing Git..." -ForegroundColor DarkGray
git init -q

# 2. Create README
"# $ProjectName`n`nCreated on $(Get-Date)`nType: $Type" | Out-File "README.md" -Encoding UTF8

# 3. Language Specific Logic
switch ($Type) {
    "Python" {
        "__pycache__/`n*.pyc`n.venv/`n.env`n.DS_Store`n.pytest_cache/" | Out-File ".gitignore" -Encoding UTF8
        if ($Simple) {
            "def main():`n    print('Quick script running...')`n`nif __name__ == '__main__':`n    main()" | Out-File "main.py" -Encoding UTF8
        } else {
            New-Item -Type Directory -Path "src", "tests" | Out-Null
            New-Item -Type File -Path "src/__init__.py" | Out-Null
            "def main():`n    print('Hello from $ProjectName')`n`nif __name__ == '__main__':`n    main()" | Out-File "src/main.py" -Encoding UTF8
            "pytest`nblack`nflake8" | Out-File "requirements.txt" -Encoding UTF8
        }
        if (Get-Command "python3" -ErrorAction SilentlyContinue) {
            Write-Host "Creating Venv..." -ForegroundColor Yellow
            python3 -m venv .venv
            if ($IsMacOS -or $IsLinux) {
                "source .venv/bin/activate" | Out-File "activate.sh" -Encoding UTF8
                chmod +x activate.sh
            }
        }
    }
    "PowerShell" {
        New-Item -Type Directory -Path "src", "tests", "output" | Out-Null
        "Write-Host 'Hello from $ProjectName'" | Out-File "src/$ProjectName.ps1" -Encoding UTF8
        "Describe '$ProjectName' {`n    It 'Should exist' {`n        1 | Should -Be 1`n    }`n}" | Out-File "tests/$ProjectName.Tests.ps1" -Encoding UTF8
        "output/`n*.log`n.DS_Store" | Out-File ".gitignore" -Encoding UTF8
    }
    "Terraform" {
        New-Item -Type Directory -Path "modules" | Out-Null
        'terraform {`n  required_providers {`n    aws = {`n      source  = "hashicorp/aws"`n      version = "~> 4.0"`n    }`n  }`n}' | Out-File "versions.tf" -Encoding UTF8
        'provider "aws" {`n  region = "us-east-1"`n}' | Out-File "provider.tf" -Encoding UTF8
        'variable "project_name" {`n  default = "' + $ProjectName + '"`n}' | Out-File "variables.tf" -Encoding UTF8
        ".terraform/`n*.tfstate`n*.tfstate.backup`n*.tfvars`n.DS_Store" | Out-File ".gitignore" -Encoding UTF8
        Write-Host ">> Run 'terraform init' to start." -ForegroundColor Yellow
    }
    "Docker" {
        "FROM alpine:latest`nCMD [`"echo`", `"Hello from $ProjectName`"]" | Out-File "Dockerfile" -Encoding UTF8
        "version: '3.8'`nservices:`n  app:`n    build: .`n    container_name: $ProjectName" | Out-File "docker-compose.yml" -Encoding UTF8
        ".git`n.DS_Store`nnode_modules`n.venv" | Out-File ".dockerignore" -Encoding UTF8
        Write-Host ">> Run 'docker-compose up --build' to start." -ForegroundColor Yellow
    }
    "Go" {
        New-Item -Type Directory -Path "cmd/$ProjectName", "pkg", "internal" | Out-Null
        "package main`n`nimport `"fmt`"`n`nfunc main() {`n    fmt.Println(`"Hello $ProjectName`")`n}" | Out-File "cmd/$ProjectName/main.go" -Encoding UTF8
        "$ProjectName`n*.exe`n.DS_Store" | Out-File ".gitignore" -Encoding UTF8
        Write-Host ">> Run 'go mod init $ProjectName' to finish setup." -ForegroundColor Yellow
    }
    "Web" {
        New-Item -Type Directory -Path "css", "js", "assets" | Out-Null
        "<!DOCTYPE html>`n<html lang='en'>`n<head>`n    <meta charset='UTF-8'>`n    <title>$ProjectName</title>`n    <link rel='stylesheet' href='css/style.css'>`n</head>`n<body>`n    <h1>$ProjectName</h1>`n    <script src='js/app.js'></script>`n</body>`n</html>" | Out-File "index.html" -Encoding UTF8
        "body { font-family: sans-serif; }" | Out-File "css/style.css" -Encoding UTF8
        "console.log('App Loaded');" | Out-File "js/app.js" -Encoding UTF8
        "node_modules/`n.DS_Store" | Out-File ".gitignore" -Encoding UTF8
    }
}

Write-Host "`n[SUCCESS] Project created at: $FullPath" -ForegroundColor Green

# --- Open VS Code (Unless -NoCode is passed) ---
if (-not $NoCode) {
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        code .
    }
}
