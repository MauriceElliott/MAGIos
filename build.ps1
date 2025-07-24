# MAGIos Build Script - Windows PowerShell Version
# Automated build system for MAGIos operating system on Windows

param(
    [switch]$SkipDependencies,
    [switch]$Clean,
    [switch]$Run,
    [switch]$Debug
)

# Enable strict error handling
$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "MAGIos Build System for Windows" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# === PLATFORM CHECK ===
if ($PSVersionTable.Platform -and $PSVersionTable.Platform -ne "Win32NT") {
    Write-Host "ERROR: This script is designed for Windows only." -ForegroundColor Red
    Write-Host "For other systems, use the appropriate build script." -ForegroundColor Red
    exit 1
}

# === UTILITY FUNCTIONS ===
function Test-CommandExists {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Install-Chocolatey {
    if (-not (Test-CommandExists choco)) {
        Write-Host "❌ Chocolatey not found!" -ForegroundColor Red
        Write-Host "Installing Chocolatey (package manager for Windows)..." -ForegroundColor Yellow

        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        # Refresh environment variables
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

        Write-Host "✅ Chocolatey installed" -ForegroundColor Green
    } else {
        Write-Host "✅ Chocolatey found" -ForegroundColor Green
    }
}

function Install-SwiftToolchain {
    Write-Host "Checking Swift Embedded toolchain..." -ForegroundColor Yellow

    # Check if Swift is already installed and is a development snapshot
    if (Test-CommandExists swift) {
        $swiftVersion = swift --version 2>$null
        if ($swiftVersion -match "6\.1" -or $swiftVersion -match "main") {
            Write-Host "✅ Swift development toolchain found" -ForegroundColor Green
            return
        }
    }

    Write-Host "❌ Swift development toolchain not found" -ForegroundColor Red
    Write-Host "Please download and install the Swift Development Snapshot from:" -ForegroundColor Yellow
    Write-Host "https://www.swift.org/download/#snapshots" -ForegroundColor Cyan
    Write-Host "Make sure to install the 'Trunk Development (main)' toolchain" -ForegroundColor Yellow
    Write-Host "After installation, restart PowerShell and run this script again." -ForegroundColor Yellow

    $response = Read-Host "Do you want to open the download page? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Start-Process "https://www.swift.org/download/#snapshots"
    }

    exit 1
}

function Install-CrossCompiler {
    Write-Host "Checking cross-compiler toolchain..." -ForegroundColor Yellow

    if (Test-CommandExists i686-elf-gcc) {
        Write-Host "✅ i686-elf-gcc cross-compiler found" -ForegroundColor Green
        return
    }

    Write-Host "❌ Cross-compiler not found, installing..." -ForegroundColor Red
    Write-Host "Installing MSYS2 and cross-compilation tools..." -ForegroundColor Yellow

    try {
        # Install MSYS2 if not present
        if (-not (Test-Path "C:\msys64\usr\bin\bash.exe")) {
            choco install msys2 -y
        }

        Write-Host "Setting up cross-compiler in MSYS2..." -ForegroundColor Yellow
        Write-Host "This may take several minutes..." -ForegroundColor Yellow

        # Install cross-compiler tools via MSYS2
        & "C:\msys64\usr\bin\bash.exe" -lc "pacman -S --noconfirm base-devel mingw-w64-x86_64-toolchain"
        & "C:\msys64\usr\bin\bash.exe" -lc "pacman -S --noconfirm mingw-w64-x86_64-cross-gcc"

        # Add MSYS2 tools to PATH
        $msys2Path = "C:\msys64\mingw64\bin;C:\msys64\usr\bin"
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$msys2Path*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$msys2Path", "User")
            $env:PATH += ";$msys2Path"
        }

        Write-Host "✅ Cross-compiler installed via MSYS2" -ForegroundColor Green

    } catch {
        Write-Host "⚠️ MSYS2 installation failed, trying alternative..." -ForegroundColor Yellow
        Write-Host "Please manually install cross-compiler tools:" -ForegroundColor Red
        Write-Host "1. Install MSYS2 from https://www.msys2.org/" -ForegroundColor Yellow
        Write-Host "2. Run: pacman -S base-devel mingw-w64-x86_64-toolchain" -ForegroundColor Yellow
        Write-Host "3. Add C:\msys64\mingw64\bin to your PATH" -ForegroundColor Yellow
        exit 1
    }
}

function Install-BuildTools {
    Write-Host "Installing build tools..." -ForegroundColor Yellow

    $tools = @(
        @{Name="NASM"; Package="nasm"; Command="nasm"},
        @{Name="QEMU"; Package="qemu"; Command="qemu-system-i386"},
        @{Name="Make"; Package="make"; Command="make"}
    )

    foreach ($tool in $tools) {
        if (-not (Test-CommandExists $tool.Command)) {
            Write-Host "❌ $($tool.Name) not found, installing..." -ForegroundColor Red
            try {
                choco install $tool.Package -y
                Write-Host "✅ $($tool.Name) installed" -ForegroundColor Green
            } catch {
                Write-Host "⚠️ Failed to install $($tool.Name) via Chocolatey" -ForegroundColor Yellow
                Write-Host "Please install manually from official sources" -ForegroundColor Yellow
            }
        } else {
            Write-Host "✅ $($tool.Name) found" -ForegroundColor Green
        }
    }
}

# === DEPENDENCY INSTALLATION ===
if (-not $SkipDependencies) {
    Write-Host "Checking and installing dependencies..." -ForegroundColor Cyan
    Write-Host "-------------------------------------" -ForegroundColor Cyan

    Install-Chocolatey
    Install-SwiftToolchain
    Install-CrossCompiler
    Install-BuildTools

    Write-Host ""
    Write-Host "✅ All dependencies checked!" -ForegroundColor Green
    Write-Host ""
}

# === CREATE REQUIRED DIRECTORIES ===
Write-Host "Setting up build environment..." -ForegroundColor Yellow
if (-not (Test-Path "build")) { New-Item -ItemType Directory -Name "build" | Out-Null }
if (-not (Test-Path "src")) { New-Item -ItemType Directory -Name "src" | Out-Null }
if (-not (Test-Path "iso")) { New-Item -ItemType Directory -Name "iso" | Out-Null }
if (-not (Test-Path "swift-src")) { New-Item -ItemType Directory -Name "swift-src" | Out-Null }

# === CLEAN BUILD ===
if ($Clean) {
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-CommandExists make) {
        make clean 2>$null | Out-Null
    }
    if (Test-Path "build") { Remove-Item -Recurse -Force "build\*" -ErrorAction SilentlyContinue }
    if (Test-Path "iso") { Remove-Item -Recurse -Force "iso\*" -ErrorAction SilentlyContinue }
    if (Test-Path "magios.iso") { Remove-Item -Force "magios.iso" -ErrorAction SilentlyContinue }
    Write-Host "✅ Clean complete" -ForegroundColor Green
}

# === BUILD PROCESS ===
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Building MAGIos Kernel with Embedded Swift..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Build Swift components first
Write-Host "🔨 Compiling Swift components..." -ForegroundColor Yellow
if (Test-Path "swift-src\Package.swift") {
    Push-Location "swift-src"
    try {
        swift build --triple i686-unknown-none-elf -c release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Swift compilation successful!" -ForegroundColor Green
        } else {
            Write-Host "❌ Swift compilation failed!" -ForegroundColor Red
            exit 1
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "⚠️ No Swift package found, creating basic structure..." -ForegroundColor Yellow
}

# Build C/Assembly components
Write-Host "🔨 Compiling C/Assembly components..." -ForegroundColor Yellow
if (Test-CommandExists make) {
    # Try Swift-enabled Makefile first, then fall back to regular Makefile
    if (Test-Path "Makefile.swift") {
        make -f Makefile.swift all
        $buildResult = $LASTEXITCODE
    } else {
        make all
        $buildResult = $LASTEXITCODE
    }

    if ($buildResult -eq 0) {
        Write-Host "✅ C/Assembly compilation successful!" -ForegroundColor Green
    } else {
        Write-Host "❌ C/Assembly compilation failed!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- Cross-compiler not properly installed" -ForegroundColor Yellow
        Write-Host "- Source files missing or corrupted" -ForegroundColor Yellow
        Write-Host "- Linker script errors" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Try running: make check-tools" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "❌ Make not found, cannot build" -ForegroundColor Red
    exit 1
}

# Create bootable ISO
Write-Host "📀 Creating bootable ISO..." -ForegroundColor Yellow
if (Test-Path "Makefile.swift") {
    make -f Makefile.swift iso
} else {
    make iso
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ ISO creation successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "🎉 MAGIos Build Complete!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your Evangelion-themed OS is ready!" -ForegroundColor Magenta
    Write-Host "ISO file: magios.iso" -ForegroundColor White
    Write-Host ""
    Write-Host "To run MAGIos:" -ForegroundColor Yellow
    Write-Host "  make run          # Run in QEMU emulator" -ForegroundColor White
    Write-Host "  make debug        # Run with debugging support" -ForegroundColor White
    Write-Host "  .\build.ps1 -Run  # Run using this script" -ForegroundColor White
    Write-Host ""
    Write-Host "Welcome to Terminal Dogma! 🤖" -ForegroundColor Magenta
} else {
    Write-Host "❌ ISO creation failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "The kernel binary was built successfully, but ISO creation failed." -ForegroundColor Yellow
    Write-Host "This might be due to missing grub-mkrescue tools." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can still test the kernel binary directly:" -ForegroundColor White
    Write-Host "  qemu-system-i386 -kernel build/kernel.bin" -ForegroundColor Cyan
    exit 1
}

# === RUN OPTIONS ===
if ($Run) {
    Write-Host ""
    Write-Host "🚀 Launching MAGIos in QEMU..." -ForegroundColor Green
    if (Test-CommandExists make) {
        make run
    } else {
        Write-Host "❌ Make not found for running" -ForegroundColor Red
    }
}

if ($Debug) {
    Write-Host ""
    Write-Host "🐛 Launching MAGIos in debug mode..." -ForegroundColor Yellow
    Write-Host "Connect with GDB to localhost:1234" -ForegroundColor Cyan
    if (Test-CommandExists make) {
        make debug
    } else {
        Write-Host "❌ Make not found for debugging" -ForegroundColor Red
    }
}

# === FINAL SYSTEM INFO ===
Write-Host ""
Write-Host "System Information:" -ForegroundColor Cyan
Write-Host "-------------------" -ForegroundColor Cyan
Write-Host "Windows Version: $([System.Environment]::OSVersion.VersionString)" -ForegroundColor White
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host "Architecture: $([System.Environment]::ProcessorArchitecture)" -ForegroundColor White
if (Test-Path "build\kernel.bin") {
    $kernelSize = (Get-Item "build\kernel.bin").Length
    Write-Host "Kernel Binary: build\kernel.bin ($([math]::Round($kernelSize/1024, 2)) KB)" -ForegroundColor White
}
if (Test-Path "magios.iso") {
    $isoSize = (Get-Item "magios.iso").Length
    Write-Host "ISO Image: magios.iso ($([math]::Round($isoSize/1024/1024, 2)) MB)" -ForegroundColor White
}
Write-Host ""
Write-Host "Happy hacking! 🚀" -ForegroundColor Green

# === USAGE EXAMPLES ===
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Cyan
Write-Host "  .\build.ps1                    # Build everything" -ForegroundColor White
Write-Host "  .\build.ps1 -Clean             # Clean and build" -ForegroundColor White
Write-Host "  .\build.ps1 -Run               # Build and run" -ForegroundColor White
Write-Host "  .\build.ps1 -SkipDependencies  # Skip dependency check" -ForegroundColor White
Write-Host "  .\build.ps1 -Debug             # Build and debug" -ForegroundColor White
