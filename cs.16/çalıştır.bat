@echo off
setlocal

:: inject-prompt.bat
set /p PID=Enjekte edilecek process ID (PID) girin: 
if "%PID%"=="" (
  echo Iptal edildi.
  pause
  exit /b 1
)

:: basit sayı kontrolü
for /f "delims=0123456789" %%A in ("%PID%") do (
  echo Girdi numeric degil.
  pause
  exit /b 1
)

set "DLL=Multihack by eVOL.dll"
set "INJECTOR=%~dp0dllInjector-x86.exe"

echo Enjekte ediliyor -> PID: %PID%  DLL: "%DLL%"
"%INJECTOR%" -p %PID% -l "%DLL%" -P -c
echo Bitti.
pause
endlocal
