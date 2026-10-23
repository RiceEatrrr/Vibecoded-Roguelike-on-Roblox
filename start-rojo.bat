@echo off
rem Double-click to sync this repo into Roblox Studio.
rem First run downloads Rojo and installs the Studio plugin.
cd /d "%~dp0"

if not exist rojo.exe (
    echo Downloading Rojo...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$ErrorActionPreference='Stop';" ^
        "$r = Invoke-RestMethod 'https://api.github.com/repos/rojo-rbx/rojo/releases/latest';" ^
        "$a = $r.assets | Where-Object { $_.name -like '*windows-x86_64.zip' } | Select-Object -First 1;" ^
        "Invoke-WebRequest $a.browser_download_url -OutFile rojo.zip;" ^
        "Expand-Archive rojo.zip -DestinationPath rojo-tmp -Force;" ^
        "Get-ChildItem rojo-tmp -Recurse -Filter rojo.exe | Select-Object -First 1 | Copy-Item -Destination .;" ^
        "Remove-Item rojo.zip, rojo-tmp -Recurse -Force"
    if not exist rojo.exe (
        echo.
        echo Could not download Rojo. Check your internet connection and try again.
        pause
        exit /b 1
    )
    echo Installing the Rojo plugin into Roblox Studio...
    rojo.exe plugin install
    echo.
    echo Done. If Studio was open, restart it so the Rojo plugin shows up.
    echo.
)

echo Starting Rojo. Keep this window open while you work.
echo In Studio: Plugins tab, Rojo, Connect.
echo.
rojo.exe serve
pause
