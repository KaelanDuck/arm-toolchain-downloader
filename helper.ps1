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
    Invoke-WebRequest -Uri "https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-win32.zip" -OutFile "temp\gcc.zip"
    Write-Output "Downloading build tools"
    Invoke-WebRequest -Uri "https://github.com/gnu-mcu-eclipse/windows-build-tools/releases/download/v2.11-20180428/gnu-mcu-eclipse-build-tools-2.11-20180428-1604-win32.zip" -OutFile "temp\buildtools.zip"
    Write-Output "Downloading netcat"
    Invoke-WebRequest -Uri "https://eternallybored.org/misc/netcat/netcat-win32-1.12.zip" -Outfile "temp\netcat.zip"
    Write-Output "Downloading python 3"
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.7.1/python-3.7.1-embed-win32.zip" -OutFile "temp\python.zip"
    Write-Output "Downloading openocd"
    Invoke-WebRequest -Uri "https://github.com/gnu-mcu-eclipse/openocd/releases/download/v0.10.0-10-20181020/gnu-mcu-eclipse-openocd-0.10.0-10-20181020-0522-win32.zip" -OutFile "temp\openocd.zip"
    Write-Output "Downloading git"
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.19.1.windows.1/MinGit-2.19.1-32-bit.zip" -OutFile "temp\git.zip"

    Expand-Archive -Path "temp\mingw-get-setup.zip" -DestinationPath "temp\mingw"

    Write-Output "Downloading MSYS"
    .\temp\mingw\bin\mingw-get.exe install msys-coreutils-bin

    New-Item -ItemType Directory -Name "toolchain" > $null

    Expand-Archive -Path "temp\gcc.zip" -DestinationPath "toolchain\gcc-arm"
    Expand-Archive -Path "temp\buildtools.zip" -DestinationPath "temp"
    Move-Item -Path "temp\GNU MCU Eclipse\Build Tools\2.11-20180428-1604\bin" -Destination "toolchain\build-tools"
    Move-Item -Path "temp\mingw\msys\1.0" -Destination "toolchain\msys"
    Expand-Archive -Path "temp\netcat.zip" -DestinationPath "temp\netcat"
    Move-Item -Path "temp\netcat\nc.exe" "toolchain\build-tools"
    Expand-Archive -Path "temp\python.zip" -DestinationPath "toolchain\python"
    Expand-Archive -Path "temp\openocd.zip" -DestinationPath "temp\openocd"
    Move-Item -Path ".\temp\openocd\GNU MCU Eclipse\OpenOCD\0.10.0-10-20181020-0522" -Destination "toolchain\openocd"
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
