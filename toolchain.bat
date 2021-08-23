<# ::
@echo off
set ps1="%TEMP%\%RANDOM%%RANDOM%-%~n0.ps1"
copy /y "%~f0" %ps1% >NUL && powershell -NoProfile -ExecutionPolicy Bypass -File %ps1% %*
set ec=%ERRORLEVEL% & del %ps1%
exit /b %ec%
#>

# powershell runs from this line


$ErrorActionPreference = "Stop"

$paths = "$pwd\toolchain\gcc-arm\bin",
    "$pwd\toolchain\build-tools",
    "$pwd\toolchain\msys\bin",
    "$pwd\toolchain\openocd\bin",
    "$pwd\toolchain\python",
    "$pwd\toolchain\git\cmd",
    "$env:Path"

$env:Path = ($paths -Join ";")

if ((Test-Path -Path "toolchain") -And -Not (Test-Path -Path "temp")) {
    $host.ui.RawUI.WindowTitle = "ARM development environment"
    PowerShell
    exit
}

Write-Output "The toolchain will now be downloaded"

Remove-Item -ErrorAction Ignore -Recurse "toolchain" > $null
Remove-Item -ErrorAction Ignore -Recurse "temp" > $null

try {

    New-Item -ItemType Directory -Name "temp" > $null

    Write-Output "`n`n`n`n"

    # fixes python.org
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

    Write-Output "Downloading mingw-get"
    Invoke-WebRequest -Uri "https://nchc.dl.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip" -OutFile "temp\mingw-get-setup.zip"
    Write-Output "Downloading gcc"
    Invoke-WebRequest -Uri "https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-win32.zip" -OutFile "temp\gcc.zip"
    Write-Output "Downloading build tools"
    Invoke-WebRequest -Uri "https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/download/v4.2.1-2/xpack-windows-build-tools-4.2.1-2-win32-x64.zip" -OutFile "temp\buildtools.zip"
    Write-Output "Downloading netcat"
    Invoke-WebRequest -Uri "https://eternallybored.org/misc/netcat/netcat-win32-1.12.zip" -Outfile "temp\netcat.zip"
    Write-Output "Downloading python 3"
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.9.6/python-3.9.6-embed-amd64.zip" -OutFile "temp\python.zip"
    Write-Output "Downloading openocd"
    Invoke-WebRequest -Uri "https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.11.0-1/xpack-openocd-0.11.0-1-win32-x64.zip" -OutFile "temp\openocd.zip"
    Write-Output "Downloading git"
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/MinGit-2.31.1-busybox-64-bit.zip" -OutFile "temp\git.zip"

    Expand-Archive -Path "temp\mingw-get-setup.zip" -DestinationPath "temp\mingw"

    Write-Output "Downloading MSYS"
    .\temp\mingw\bin\mingw-get.exe install msys-coreutils-bin

    New-Item -ItemType Directory -Name "toolchain" > $null

    Expand-Archive -Path "temp\gcc.zip" -DestinationPath "temp"
    Move-Item -Path "temp\gcc-arm-none-eabi-10.3-2021.07" -Destination "toolchain\gcc-arm"
    Expand-Archive -Path "temp\buildtools.zip" -DestinationPath "temp"
    Move-Item -Path "temp\xpack-windows-build-tools-4.2.1-2\bin" -Destination "toolchain\build-tools"
    Move-Item -Path "temp\mingw\msys\1.0" -Destination "toolchain\msys"
    Expand-Archive -Path "temp\netcat.zip" -DestinationPath "temp\netcat"
    Move-Item -Path "temp\netcat\nc.exe" "toolchain\build-tools"
    Expand-Archive -Path "temp\python.zip" -DestinationPath "toolchain\python"
    Copy-Item -Path "toolchain\python\python.exe" -Destination "toolchain\python\python3.exe" # libopencm3 requires 'python3'
    Expand-Archive -Path "temp\openocd.zip" -DestinationPath "temp\openocd"
    Move-Item -Path ".\temp\openocd\xpack-openocd-0.11.0-1\" -Destination "toolchain\openocd"
    Expand-Archive -Path "temp\git.zip" -DestinationPath "toolchain\git"

    Remove-Item -Recurse "temp" > $null

    Write-Output "Successfully downloaded the toolchain"
    Write-Output "Press any key to continue..."
    [void][System.Console]::ReadKey($true)

} catch {
    Write-Output "Failed to download and/or install toolchain"
    Write-Output "Press any key to continue..."
    [void][System.Console]::ReadKey($true)
}
