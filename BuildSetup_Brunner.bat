echo off

SET BuildMode=Release
REM SET BuildMode=Debug

SET VS=2022\Community
SET BUILDER=%ProgramFiles%\Microsoft Visual Studio\%VS%\MSBuild\Current\Bin\MSBuild.exe
SET Target64=x64\%BuildMode%
SET Target32=Win32\%BuildMode%
SET InnoCompiler=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe


:inno
echo %DATE% %TIME%: Compiling the Inno Setup Script
IF NOT EXIST "%InnoCompiler%" GOTO NOINNO
"%InnoCompiler%" install\vJoyInstallerSigned.iss 
set INNO_STATUS=%ERRORLEVEL%
if not %INNO_STATUS%==0 goto fail
echo %DATE% %TIME%: Compiling the Inno Setup Script - OK
echo %DATE% %TIME%: Signing the setup
signtool sign /fd SHA256 /f "I:\Work\Int\Code Signing Certificate\EntrustCertificate.crt" /t "http://timestamp.comodoca.com/authenticode" "install/vJoySetup.exe"
exit /b 0

:NOINNO
echo %DATE% %TIME%: Could not find Inno Setup Compiler
goto fail

:fail
exit /b 1
