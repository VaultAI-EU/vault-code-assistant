# Script de build complet pour VaultAI VSCode Extension
# Usage: .\scripts\build-all.ps1 [-Target <platform-arch>] [-PreRelease] [-SkipGui]

param(
    [string]$Target = "",
    [switch]$PreRelease = $false,
    [switch]$SkipGui = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 VaultAI Extension Build Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get directories
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VsCodeDir = Split-Path -Parent $ScriptDir
$RootDir = Split-Path -Parent (Split-Path -Parent $VsCodeDir)
$GuiDir = Join-Path $RootDir "gui"

Write-Host "📁 Directories:" -ForegroundColor Yellow
Write-Host "  - Root: $RootDir"
Write-Host "  - GUI: $GuiDir"
Write-Host "  - VSCode: $VsCodeDir"
Write-Host ""

# Step 1: Build the GUI (React app)
if (-not $SkipGui) {
    Write-Host "📦 Step 1/4: Building GUI (React app)..." -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Cyan
    Push-Location $GuiDir
    
    try {
        # Check if dist exists and has content
        $distPath = Join-Path $GuiDir "dist"
        if (Test-Path $distPath) {
            $distContent = Get-ChildItem $distPath -ErrorAction SilentlyContinue
            if ($distContent) {
                Write-Host "⚠️  Warning: gui/dist already exists" -ForegroundColor Yellow
                $response = Read-Host "Do you want to rebuild it? (y/N)"
                if ($response -match "^[Yy]$") {
                    Write-Host "🗑️  Cleaning old build..." -ForegroundColor Yellow
                    Remove-Item -Path $distPath -Recurse -Force
                    Write-Host "🔨 Building GUI..." -ForegroundColor Green
                    npm run build
                } else {
                    Write-Host "✅ Using existing GUI build" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "🔨 Building GUI..." -ForegroundColor Green
            npm run build
        }
        
        # Verify the build was successful
        $indexJs = Join-Path $distPath "assets\index.js"
        $indexCss = Join-Path $distPath "assets\index.css"
        
        if (-not (Test-Path $indexJs)) {
            throw "GUI build failed - dist/assets/index.js not found"
        }
        
        if (-not (Test-Path $indexCss)) {
            throw "GUI build failed - dist/assets/index.css not found"
        }
        
        Write-Host "✅ GUI build completed successfully" -ForegroundColor Green
        Write-Host ""
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host "⏭️  Skipping GUI build (--SkipGui flag)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 2: Run prepackage script
Write-Host "📦 Step 2/4: Running prepackage script..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Push-Location $VsCodeDir

try {
    if ($Target) {
        Write-Host "🎯 Target platform: $Target" -ForegroundColor Yellow
        node scripts/prepackage.js --target $Target
    } else {
        Write-Host "🎯 Auto-detecting platform..." -ForegroundColor Yellow
        node scripts/prepackage.js
    }
    
    Write-Host "✅ Prepackage completed" -ForegroundColor Green
    Write-Host ""
    
    # Step 3: Compile TypeScript
    Write-Host "📦 Step 3/4: Compiling TypeScript..." -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Cyan
    npm run esbuild
    Write-Host "✅ TypeScript compilation completed" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Package the extension
    Write-Host "📦 Step 4/4: Packaging extension..." -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Cyan
    
    $packageArgs = @()
    if ($Target) {
        $packageArgs += "--target", $Target
    }
    if ($PreRelease) {
        $packageArgs += "--pre-release"
    }
    
    if ($packageArgs.Count -gt 0) {
        node scripts/package.js @packageArgs
    } else {
        node scripts/package.js
    }
    
    Write-Host ""
    Write-Host "🎉 Build completed successfully!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Find and display the VSIX file
    $buildDir = Join-Path $VsCodeDir "build"
    $vsixFile = Get-ChildItem -Path $buildDir -Filter "*.vsix" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($vsixFile) {
        $vsixSize = "{0:N2} MB" -f ($vsixFile.Length / 1MB)
        Write-Host "📦 Extension package created:" -ForegroundColor Green
        Write-Host "   File: $($vsixFile.FullName)"
        Write-Host "   Size: $vsixSize"
        Write-Host ""
        Write-Host "To install: code --install-extension `"$($vsixFile.FullName)`"" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  Warning: Could not find VSIX file in build directory" -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}
