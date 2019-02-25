@echo off

echo *** Verifying BitDust installation files
set CURRENT_PATH=%cd%
set BITDUST_FULL_HOME=%HOMEDRIVE%%HOMEPATH%\.bitdust
set PYTHON_ZIP=%CURRENT_PATH%\resources\app\build_resources\win\python.zip
set GIT_ZIP=%CURRENT_PATH%\resources\app\build_resources\win\git.zip
set UNZIP_EXE=%CURRENT_PATH%\resources\app\build_resources\win\unzip.exe


echo *** Destination folder is %BITDUST_FULL_HOME%
if not exist "%BITDUST_FULL_HOME%" echo Prepare destination folder %BITDUST_FULL_HOME%
if not exist "%BITDUST_FULL_HOME%" mkdir "%BITDUST_FULL_HOME%"


set SHORT_PATH_SCRIPT=%BITDUST_FULL_HOME%\shortpath.bat
set SHORT_PATH_OUT=%BITDUST_FULL_HOME%\shortpath.txt
if exist "%SHORT_PATH_OUT%" goto ShortPathKnown
echo *** Prepare short path to the data folder
echo @echo OFF > "%SHORT_PATH_SCRIPT%"
echo echo %%~s1 >> "%SHORT_PATH_SCRIPT%"
call "%SHORT_PATH_SCRIPT%" "%BITDUST_FULL_HOME%" > "%SHORT_PATH_OUT%"
del /q /s /f "%SHORT_PATH_SCRIPT%" >nul 2>&1
:ShortPathKnown
set /P BITDUST_HOME=<"%SHORT_PATH_OUT%"
setlocal enabledelayedexpansion
for /l %%a in (1,1,300) do if "!BITDUST_HOME:~-1!"==" " set BITDUST_HOME=!BITDUST_HOME:~0,-1!
setlocal disabledelayedexpansion
echo *** Short and safe path to BitDust home folder is %BITDUST_HOME%


set BITDUST_NODE=%BITDUST_HOME%\venv\Scripts\BitDustNode.exe
echo *** Executable file is %BITDUST_HOME%
set PYTHON_EXE=%BITDUST_HOME%\python\python.exe
echo *** python.exe is %PYTHON_EXE%
set GIT_EXE=%BITDUST_HOME%\git\bin\git.exe
echo *** git.exe is %GIT_EXE%


if /I "%~1"=="stop" goto StopBitDust
goto StartBitDust
:StopBitDust
echo *** Stopping BitDust ...
cd /D "%BITDUST_HOME%"
if not exist %BITDUST_NODE% goto KillBitDust
echo "%BITDUST_NODE%" "%BITDUST_HOME%\src\bitdust.py stop"
%BITDUST_NODE% %BITDUST_HOME%\src\bitdust.py stop
:KillBitDust
taskkill /IM BitDustNode.exe /F /T
:BitDustStopped
echo *** BitDust process stopped, DONE!
exit /b %errorlevel%


:StartBitDust
echo *** Prepare to start BitDust


echo *** Checking for python binaries in the destination folder %BITDUST_HOME%\python\
if exist %PYTHON_EXE% goto PythonInstalled
:PythonToBeInstalled
echo *** Extract Python binaries to the destination folder %BITDUST_HOME%
%UNZIP_EXE% -o -q %PYTHON_ZIP% -d %BITDUST_HOME%
if %errorlevel% neq 0 goto DEPLOY_ERROR
:PythonInstalled
echo *** Python binaries located in %BITDUST_HOME%\python


echo *** Checking for git binaries in the destination folder
if exist %GIT_EXE% goto GitInstalled
echo *** Extract Python binaries to the destination folder %BITDUST_HOME%
%UNZIP_EXE% -o -q %GIT_ZIP% -d %BITDUST_HOME%
if %errorlevel% neq 0 goto DEPLOY_ERROR
:GitInstalled
echo *** Git binaries located in %BITDUST_HOME%\git


echo *** Checking BitDust engine sources
if not exist %BITDUST_HOME%\src mkdir %BITDUST_HOME%\src
cd /D %BITDUST_HOME%\src


if exist %BITDUST_HOME%\src\bitdust.py goto SourcesExist
echo *** Downloading BitDust software using "git clone" from GitHub repository
%BITDUST_HOME%\git\bin\git.exe clone -q --depth 1 https://github.com/bitdust-io/devel.git .
if %errorlevel% neq 0 goto DEPLOY_ERROR
:SourcesExist


echo *** Running command "git clean" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe clean -q -d -f -x .
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo *** Running command "git fetch" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe fetch --all
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo *** Running command "git reset" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe reset --hard origin/master
if %errorlevel% neq 0 goto DEPLOY_ERROR


echo *** Checking BitDust virtual environment
if exist %BITDUST_HOME%\venv goto VenvUpdate
echo *** Deploy BitDust virtual environment
%PYTHON_EXE% bitdust.py install
if %errorlevel% neq 0 goto DEPLOY_ERROR
goto VenvOk
:VenvUpdate
echo *** Update BitDust requirements
%BITDUST_HOME%\venv\Scripts\pip.exe install -U -r %BITDUST_HOME%\src\requirements.txt
if %errorlevel% neq 0 goto DEPLOY_ERROR
:VenvOk


cd /D %BITDUST_HOME%


echo *** Check BitDustNode.exe "alias" created in %BITDUST_NODE%
if exist %BITDUST_NODE% goto BitDustNodeExeExist
copy /B /Y %BITDUST_HOME%\venv\Scripts\pythonw.exe %BITDUST_NODE%
echo *** Copied %BITDUST_HOME%\venv\Scripts\pythonw.exe to %BITDUST_NODE% 
:BitDustNodeExeExist


echo *** Checking BitDust UI sources
if not exist %BITDUST_HOME%\ui mkdir %BITDUST_HOME%\ui
if exist %BITDUST_HOME%\ui\index.html goto UISourcesExist
echo *** Downloading BitDust UI using "git clone" from GitHub repository
%BITDUST_HOME%\git\bin\git.exe clone -q --depth 1 https://github.com/bitdust-io/web.git ui
if %errorlevel% neq 0 goto DEPLOY_ERROR
:UISourcesExist


cd /D %BITDUST_HOME%\ui\
echo *** Running command "git clean" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe clean -q -d -f -x .
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo *** Running command "git fetch" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe fetch --all
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo *** Running command "git reset" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe reset --hard origin/master
if %errorlevel% neq 0 goto DEPLOY_ERROR


echo *** DEPLOY SUCCESS
goto DEPLOY_SUCCESS


:DEPLOY_ERROR
echo *** DEPLOYMENT FAILED
echo.
exit /b %errorlevel%


:DEPLOY_SUCCESS
echo *** Starting BitDust daemon
cd /D "%BITDUST_HOME%"
%BITDUST_NODE% %BITDUST_HOME%\src\bitdust.py daemon
cd /D "%CURRENT_PATH%"
echo *** DONE
echo.
