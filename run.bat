@echo off
setlocal EnableDelayedExpansion

set VERSION_FILE=.botica-director-version
set DIRECTOR_JAR=botica-director.jar
set LATEST_RELEASE_URL=https://api.github.com/repos/isa-group/botica/releases/latest
set DOWNLOAD_URL=https://github.com/isa-group/botica/releases/latest/download/botica-director.jar
set JAVA_CMD=

call :CheckJavaVersion
if %ERRORLEVEL% neq 0 exit /b 1

call :GetLatestRelease
if %ERRORLEVEL% neq 0 (
    if exist "%DIRECTOR_JAR%" (
        echo Warning: Failed to fetch the latest release version. Please check your internet connection.
    ) else (
        echo Error: Failed to download Botica Director. Please check your internet connection and try again.
        exit /b 1
    )
) else (
    if exist "%DIRECTOR_JAR%" if exist "%VERSION_FILE%" (
        set /p LOCAL_VERSION=<"%VERSION_FILE%"
        if not "!LATEST_VERSION!"=="!LOCAL_VERSION!" (
            echo A new version (!LATEST_VERSION!) is available.
            call :DownloadBoticaDirector
        )
    ) else (
        call :DownloadBoticaDirector
    )
)

"%JAVA_CMD%" -jar %DIRECTOR_JAR% %*
exit /b 0

:CheckJavaVersion
where java >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set JAVA_CMD=java
) else if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" (
    set JAVA_CMD=%JAVA_HOME%\bin\java.exe
) else (
    echo Error: Java is not installed on this machine. Please install Java 11 or higher and try again.
    exit /b 1
)

for /f "tokens=1,2,3 delims=._" %%a in ('"%JAVA_CMD%" -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VER=%%b
)

if %JAVA_VER% geq 11 (
    exit /b 0
) else (
    echo Error: you need at least Java 11 to run Botica. Found version: %JAVA_VER%. Please install Java 11 or higher and try again.
    exit /b 1
)

:GetLatestRelease
for /f "delims=" %%a in ('powershell -Command "(Invoke-RestMethod -Uri '%LATEST_RELEASE_URL%').tag_name"') do (
    set LATEST_VERSION=%%a
)
if not defined LATEST_VERSION exit /b 1
exit /b 0

:DownloadBoticaDirector
echo Downloading the latest version (!LATEST_VERSION!)...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%DIRECTOR_JAR%'"
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to download Botica Director. Please check your internet connection and try again.
    exit /b 1
)
echo !LATEST_VERSION!>"%VERSION_FILE%"
exit /b 0
