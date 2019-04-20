@echo off
cd /d "%~dp0"

if NOT "%cd%"=="%cd: =%" (
    echo Current directory contains spaces in its path.
    echo Please move or rename the directory to one not containing spaces.
    echo.
    pause
    goto :EOF
)

REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1
IF %ERRORLEVEL% EQU 0 goto :START_PROCESS

set "command="""%~f0""" %*"
set "command=%command:'=''%"

powershell Start-Process -FilePath '%COMSPEC%' -ArgumentList '/c """%command%"""' -Verb RunAs 2>NUL
IF %ERRORLEVEL% GTR 0 (
    echo =====================================================
    echo This script needs to be executed as an administrator.
    echo =====================================================
    echo.
    pause
)

goto :EOF

:START_PROCESS
set "aria2=files\aria2c.exe"
set "a7z=files\7zr.exe"
set "uupConv=files\uup-converter-wimlib.7z"
set "aria2Script=files\aria2_script.txt"
set "destDir=UUPs"

if NOT EXIST %aria2% goto :NO_ARIA2_ERROR
if NOT EXIST %a7z% goto :NO_FILE_ERROR
if NOT EXIST %uupConv% goto :NO_FILE_ERROR

echo Extracting UUP converter...
"%a7z%" -y x "%uupConv%" >NUL
copy /y files\ConvertConfig.ini . >NUL
echo.

echo Retrieving updated aria2 script...
"%aria2%" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://uupdump.ml/get.php?id=ea4e1d15-0c09-45bb-aac0-5e366c04ed2d&pack=en-us&edition=0&aria2=1"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1
echo.

echo Starting download of files...
"%aria2%" -x16 -s16 -j5 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1

if EXIST convert-UUP.cmd goto :START_CONVERT
pause
goto :EOF

:START_CONVERT
call convert-UUP.cmd
goto :EOF

:NO_ARIA2_ERROR
echo We couldn't find %aria2% in current directory.
echo.
echo You can download aria2 from:
echo https://aria2.github.io/
echo.
pause
goto :EOF

:NO_FILE_ERROR
echo We couldn't find one of needed files for this script.
pause
goto :EOF

:DOWNLOAD_ERROR
echo We have encountered an error while downloading files.
pause
goto :EOF

:EOF
