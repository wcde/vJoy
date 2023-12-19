echo off

SET BuildMode=Release
REM SET BuildMode=Debug

SET VS=2022\Community
SET BUILDER=%ProgramFiles%\Microsoft Visual Studio\%VS%\MSBuild\Current\Bin\MSBuild.exe
SET Target64=x64\%BuildMode%
SET Target32=Win32\%BuildMode%

REM Skip x86 for Windows 10 and above
REM goto build64

:build32
echo %DATE% %TIME%: Cleaning vJoy (x86) 
"%BUILDER%" vJoyAll.sln  /maxcpucount:1 /t:clean /p:Platform=x86;Configuration=%BuildMode%
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

echo %DATE% %TIME%: Building vJoy (x86)
"%BUILDER%" vJoyAll.sln  /maxcpucount:4  /p:Platform=x86;Configuration=%BuildMode%
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

:build64
echo %DATE% %TIME%: Cleaning vJoy (x64)
"%BUILDER%" vJoyAll.sln  /maxcpucount:1 /t:clean /p:Platform=x64;Configuration=%BuildMode%
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

echo %DATE% %TIME%: Building vJoy (x64)
"%BUILDER%" vJoyAll.sln  /maxcpucount:4  /p:Platform=x64;Configuration=%BuildMode%
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

:signapps
echo %DATE% %TIME%: Signing the applications
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /t "http://timestamp.comodoca.com/authenticode" .\%Target64%\vJoyList.exe
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /t "http://timestamp.comodoca.com/authenticode" .\%Target64%\vJoyConf.exe
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /t "http://timestamp.comodoca.com/authenticode" .\%Target64%\vJoyFeeder.exe
set SIGN_STATUS=%ERRORLEVEL%
if not %SIGN_STATUS%==0 goto fail
echo %DATE% %TIME%: Signing the applications - OK

:signdriver
echo %DATE% %TIME%: Signing the driver
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /p beh_admin /t "http://timestamp.comodoca.com/authenticode" .\%Target64%\Package\hidkmdf.sys
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /p beh_admin /t "http://timestamp.comodoca.com/authenticode" .\%Target64%\Package\vjoy.cat
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /p beh_admin /t "http://timestamp.comodoca.com/authenticode" .\%Target64%\Package\vJoy.sys
set SIGN_STATUS=%ERRORLEVEL%
if not %SIGN_STATUS%==0 goto fail
echo %DATE% %TIME%: Signing the driver - OK

:fail
exit /b 1
