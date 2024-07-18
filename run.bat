@echo off
setlocal enabledelayedexpansion

set "DIRECTOR_JAR=botica-director.jar"
set "VERSION_FILE=botica-director-version.txt"
set "LATEST_RELEASE_URL=https://api.github.com/repos/isa-group/botica/releases/latest"
set "DOWNLOAD_URL=https://github.com/isa-group/botica/releases/latest/download/botica-director.jar"

:check_java_version
for /f "tokens=2 delims==" %%i in ('java -version 2^>^&1 ^| findstr /r "version" ^| findstr "1[1-9]"') do (
    set "JAVA_VERSION=%%i"
)
if "%JAVA_VERSION%"=="" (
    echo Error: Java is not installed or is not version 11 or higher. Please install Java 11 or higher and try again.
    exit /b 1
)
exit /b 0

call :check_java_version

:get_latest_release
for /f "tokens=3 delims=: " %%i in ('curl -s %LATEST_RELEASE_URL% ^| findstr /i "tag_name"') do (
    set "LATEST_VERSION=%%i"
    set "LATEST_VERSION=!LATEST_VERSION:"=!"
)
exit /b 0

call :get_latest_release

:download_botica_director
echo Downloading the latest version (%LATEST_VERSION%)...
curl -L -o %DIRECTOR_JAR% %DOWNLOAD_URL%
if %errorlevel% neq 0 (
    echo Error: Failed to download Botica Director. Please check your internet connection and try again.
    exit /b 1
)
echo %LATEST_VERSION% > %VERSION_FILE%
exit /b 0

if exist %DIRECTOR_JAR% (
    if exist %VERSION_FILE% (
        set /p LOCAL_VERSION=<%VERSION_FILE%
        if "%LATEST_VERSION%"=="%LOCAL_VERSION%" (
            echo The latest version (%LATEST_VERSION%) is already downloaded.
            goto run_director
        )
    )
)

call :download_botica_director

:run_director
java -jar %DIRECTOR_JAR% %*

endlocal
