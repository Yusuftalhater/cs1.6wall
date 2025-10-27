@echo off
REM show-inject-command.bat
REM - dllInjector-x86.exe -d çıktısını parse eder
REM - seçilen index için enjeksiyon komutunu OLUŞTURUR ve ÇALIŞTIRIR
REM - Güvenlik: Enjeksiyon komutunu manuel olarak çalıştırmak kullanıcı sorumluluğundadır.

setlocal enabledelayedexpansion
REM
REM ---------------DEGİSKENLER----------------
REM
REM
REM --- Ayarlar: gerektiğinde burayı güncelle ---
set "INJECTOR=%~dp0dllInjector-x86.exe"
set "DLL=Multihack by eVOL.dll"
set "INJECT_FLAGS=-P -c"
REM
REM
REM
REM
REM

if not exist "%INJECTOR%" (
  echo Hata: Injector bulunamadi: "%INJECTOR%"
  pause
  exit /b 1
)

REM Temp dosyaya dump yaz
 set "DUMPFILE=%~dp0._inject_dump.txt"
"%INJECTOR%" -d > "%DUMPFILE%" 2>&1

 if not exist "%DUMPFILE%" (
  echo Hata: Dump dosyasi olusturulamadi.
  pause
  exit /b 1
)

REM Parse et ve degiskenlere at
set /a idx=0
for /f "usebackq tokens=2* delims=[]" %%A in ("%DUMPFILE%") do (
  REM %%A => PID, %%B => kalan (process name veya label)
  set /a idx+=1
  set "PID!idx!=%%~A"
  REM Trim leading spaces from %%B
  set "NAME!idx!=%%~B"
)

if %idx%==0 (
  echo Dump'ta parse edilebilir herhangi bir PID bulunamadi.
  echo Dump dosyasi iceriği:
  type "%DUMPFILE%"
  pause
  goto :cleanup
)

echo.
echo Bulunan süreçler:
echo -------------------
for /L %%i in (1,1,%idx%) do (
  echo [%%i]    !PID%%i!    !NAME%%i!
)
echo -------------------
echo.

set /p sel=Secmek istedigin Index (iptal için bos birakir): 
if "%sel%"=="" (
  echo Iptal edildi.
  goto :cleanup
)

REM sayi kontrolu: eger icinde rakam disi varsa hata ver
for /f "delims=0123456789" %%x in ("%sel%") do (
  echo Gecersiz secim: sayi girmeniz gerekiyor.
  goto :cleanup
)

REM aralik kontrolu
if %sel% lss 1 (
  echo Gecersiz secim: 1 ile %idx% arasinda bir deger girin.
  goto :cleanup
)
if %sel% gtr %idx% (
  echo Gecersiz secim: 1 ile %idx% arasinda bir deger girin.
  goto :cleanup
)

REM secilen PID'i al
set "chosenPID=!PID%sel%!"
set "chosenName=!NAME%sel%!"

echo.
REM echo Secilen: Index=%sel%  PID=%chosenPID%  Name=%chosenName%
echo.
REM echo *** UYARI: Asagidaki komut Sadece GOSTERILDI, BOT TARAFINDAN CALISTIRILMAYACAK ***
echo.

 "%INJECTOR%" -p %chosenPID% -l "%DLL%" %INJECT_FLAGS%
echo.
REM echo Komutu calistirmak istersen:
REM echo 1) Komutu kopyalayip el ile yaz veya
REM echo 2) Asagidaki gibi bir komutla manuel calistir (yukari cift tirnak dahil):
echo.
echo     "%INJECTOR%" -p %chosenPID% -l "%DLL%" %INJECT_FLAGS%
echo.
echo Not: Bu islemin yonetici (Administrator) haklari gerektirebilecegini unutmayin.
pause

:cleanup
del /q "%DUMPFILE%" >nul 2>&1
endlocal
exit /b 0
