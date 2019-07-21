@echo off

rem Get the datetime in a format that can go in a filename.
set _my_datetime=%date%_%time%
set _my_datetime=%_my_datetime: =_%
set _my_datetime=%_my_datetime::=%
set _my_datetime=%_my_datetime:/=_%
set _my_datetime=%_my_datetime:.=_%


echo ##### Running at %_my_datetime%
set BITDUST_GIT_REPO=https://github.com/bitdust-io/public.git


echo ##### Verifying BitDust installation files
set CURRENT_PATH=%cd%
set BITDUST_FULL_HOME=%HOMEDRIVE%%HOMEPATH%\.bitdust

set PYTHON_ZIP=%CURRENT_PATH%\resources\app\build_resources\win\python.zip
set GIT_ZIP=%CURRENT_PATH%\resources\app\build_resources\win\git.zip
set UNZIP_EXE=%CURRENT_PATH%\resources\app\build_resources\win\unzip.exe

if not exist "%PYTHON_ZIP%" set PYTHON_ZIP=%CURRENT_PATH%\build_resources\win\python.zip
if not exist "%GIT_ZIP%" set GIT_ZIP=%CURRENT_PATH%\build_resources\win\git.zip
if not exist "%UNZIP_EXE%" set UNZIP_EXE=%CURRENT_PATH%\build_resources\win\unzip.exe


echo ##### My Home folder expected to be %BITDUST_FULL_HOME%
if not exist "%BITDUST_FULL_HOME%" echo Prepare destination folder %BITDUST_FULL_HOME%
if not exist "%BITDUST_FULL_HOME%" mkdir "%BITDUST_FULL_HOME%"


rem TODO : check appdata file also


echo ##### Prepare location for BitDust Home folder
set SHORT_PATH_SCRIPT=%BITDUST_FULL_HOME%\shortpath.bat
set SHORT_PATH_OUT=%BITDUST_FULL_HOME%\shortpath.txt
del /q /s /f "%SHORT_PATH_SCRIPT%" >nul 2>&1
del /q /s /f "%SHORT_PATH_OUT%" >nul 2>&1
echo @echo OFF > "%SHORT_PATH_SCRIPT%"
echo echo %%~s1 >> "%SHORT_PATH_SCRIPT%"
call "%SHORT_PATH_SCRIPT%" "%BITDUST_FULL_HOME%" > "%SHORT_PATH_OUT%"
set /P BITDUST_HOME=<"%SHORT_PATH_OUT%"
setlocal enabledelayedexpansion
for /l %%a in (1,1,300) do if "!BITDUST_HOME:~-1!"==" " set BITDUST_HOME=!BITDUST_HOME:~0,-1!
setlocal disabledelayedexpansion
del /q /s /f "%SHORT_PATH_SCRIPT%" >nul 2>&1
del /q /s /f "%SHORT_PATH_OUT%" >nul 2>&1
echo ##### Safe path to BitDust Home folder is %BITDUST_HOME%


set BITDUST_NODE=%BITDUST_HOME%\venv\Scripts\BitDustNode.exe
set BITDUST_NODE_CONSOLE=%BITDUST_HOME%\venv\Scripts\BitDustConsole.exe


echo ##### BitDust Home location is "%BITDUST_HOME%"
set PYTHON_EXE=%BITDUST_HOME%\python\python.exe
echo ##### Python process is %PYTHON_EXE%
set GIT_EXE=%BITDUST_HOME%\git\bin\git.exe
echo ##### GIT process is %GIT_EXE%


if /I "%~1"=="stop" goto StopBitDust
goto RestartBitDust
:StopBitDust
echo ##### Stopping BitDust
cd /D "%BITDUST_HOME%"
if not exist %BITDUST_NODE_CONSOLE% goto KillBitDust
echo Executing "%BITDUST_NODE_CONSOLE%" "%BITDUST_HOME%\src\bitdust.py stop"
%BITDUST_NODE_CONSOLE% %BITDUST_HOME%\src\bitdust.py stop
:KillBitDust
taskkill /IM BitDustNode.exe /F /T
rem taskkill /IM BitDustConsole.exe /F /T
:BitDustStopped
echo DONE
exit /b %errorlevel%


:RestartBitDust
if /I "%~1"=="restart" goto RestartBitDust
goto StartBitDust
:RestartBitDust
echo ##### Restarting BitDust
cd /D "%BITDUST_HOME%"
if not exist %BITDUST_NODE_CONSOLE% goto BitDustRestarted
echo Executing "%BITDUST_NODE_CONSOLE%" "%BITDUST_HOME%\src\bitdust.py restart"
%BITDUST_NODE_CONSOLE% %BITDUST_HOME%\src\bitdust.py restart
:BitDustRestarted
echo DONE
exit /b %errorlevel%


:StartBitDust
echo Prepare to start BitDust


echo Checking for python binaries in the destination folder %BITDUST_HOME%\python\
if exist %PYTHON_EXE% goto PythonInstalled
:PythonToBeInstalled
echo ##### Extracting Python binaries to %BITDUST_HOME%
%UNZIP_EXE% -o -q %PYTHON_ZIP% -d %BITDUST_HOME%
if %errorlevel% neq 0 goto DEPLOY_ERROR
:PythonInstalled
echo ##### Python binaries now located in %BITDUST_HOME%\python


echo ##### Checking for git binaries in the destination folder
if exist %GIT_EXE% goto GitInstalled
echo ##### Extract Python binaries to the destination folder %BITDUST_HOME%
%UNZIP_EXE% -o -q %GIT_ZIP% -d %BITDUST_HOME%
if %errorlevel% neq 0 goto DEPLOY_ERROR
:GitInstalled
echo ##### Git binaries now located in %BITDUST_HOME%\git


echo ##### Checking BitDust source files
if not exist %BITDUST_HOME%\src mkdir %BITDUST_HOME%\src


cd /D %BITDUST_HOME%\src


if exist %BITDUST_HOME%\src\bitdust.py goto SourcesExist
echo ##### Downloading BitDust software using "git clone" from GitHub repository
%BITDUST_HOME%\git\bin\git.exe clone -q --depth 1 %BITDUST_GIT_REPO% .
if %errorlevel% neq 0 goto DEPLOY_ERROR


:SourcesExist
rem echo ##### Running command "git clean" in BitDust repository
rem %BITDUST_HOME%\git\bin\git.exe clean -q -d -f -x .
rem if %errorlevel% neq 0 goto DEPLOY_ERROR
echo ##### Running command "git fetch" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe fetch --all
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo ##### Running command "git reset" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe reset --hard origin/master
if %errorlevel% neq 0 goto DEPLOY_ERROR


echo ##### Checking virtual environment
if exist %BITDUST_HOME%\venv\Scripts\pip.exe goto VenvUpdate
echo ##### Prepare virtual environment
%PYTHON_EXE% bitdust.py install
if %errorlevel% neq 0 goto DEPLOY_ERROR
goto VenvOk
:VenvUpdate
rem TODO: this is slow and can fail if user is offline...
rem this actually must be only executed when requirements.txt was changed
echo ##### Update Python requirements
%BITDUST_HOME%\venv\Scripts\pip.exe install -U -r %BITDUST_HOME%\src\requirements.txt
if %errorlevel% neq 0 goto DEPLOY_ERROR
:VenvOk


cd /D %BITDUST_HOME%


echo ##### Checking BitDustNode "alias" process to be created in %BITDUST_NODE%
if exist %BITDUST_NODE% goto BitDustNodeExeExist
copy /B /Y %BITDUST_HOME%\venv\Scripts\pythonw.exe %BITDUST_NODE%
echo Copied %BITDUST_HOME%\venv\Scripts\pythonw.exe to %BITDUST_NODE% 
:BitDustNodeExeExist


echo ##### Checking BitDustConsole "alias" process to be created in %BITDUST_NODE_CONSOLE%
if exist %BITDUST_NODE_CONSOLE% goto BitDustConsoleExeExist
copy /B /Y %BITDUST_HOME%\venv\Scripts\python.exe %BITDUST_NODE_CONSOLE%
echo Copied %BITDUST_HOME%\venv\Scripts\python.exe to %BITDUST_NODE_CONSOLE% 
:BitDustConsoleExeExist


echo ##### Checking BitDust UI source files
if not exist %BITDUST_HOME%\ui mkdir %BITDUST_HOME%\ui

if exist %BITDUST_HOME%\ui\dist\index.html goto UISourcesExist
echo ##### Downloading BitDust UI using "git clone" from GitHub repository
%BITDUST_HOME%\git\bin\git.exe clone -q --depth 1 https://github.com/bitdust-io/ui.git ui
if %errorlevel% neq 0 goto DEPLOY_ERROR
:UISourcesExist


cd /D %BITDUST_HOME%\ui\


rem echo ##### Running command "git clean" in BitDust UI repository
rem %BITDUST_HOME%\git\bin\git.exe clean -q -d -f -x .
rem if %errorlevel% neq 0 goto DEPLOY_ERROR
echo ##### Running command "git fetch" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe fetch --all
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo ##### Running command "git reset" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe reset --hard origin/master
if %errorlevel% neq 0 goto DEPLOY_ERROR


echo DEPLOYMENT FINISHED SUCCESSFULLY
goto DEPLOY_SUCCESS


:DEPLOY_ERROR
echo DEPLOYMENT FAILED
echo.
exit /b %errorlevel%


:DEPLOY_SUCCESS
echo ##### Starting BitDust as a daemon process
cd /D "%BITDUST_HOME%"
%BITDUST_NODE% %BITDUST_HOME%\src\bitdust.py daemon
cd /D "%CURRENT_PATH%"
echo DONE
echo.
