@echo off


echo *** Verifying BitDust installation files


set CURRENT_PATH=%cd%
set BITDUST_FULL_HOME=%HOMEDRIVE%%HOMEPATH%\.bitdust
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
del /Q "%SHORT_PATH_SCRIPT%"


:ShortPathKnown
set /P BITDUST_HOME=<"%SHORT_PATH_OUT%"
setlocal enabledelayedexpansion
for /l %%a in (1,1,300) do if "!BITDUST_HOME:~-1!"==" " set BITDUST_HOME=!BITDUST_HOME:~0,-1!
setlocal disabledelayedexpansion
echo *** Short and safe path is %BITDUST_HOME%


set TMPDIR=%TEMP%\BitDust_Install_TEMP
if not exist %TMPDIR% mkdir %TMPDIR%
echo *** Prepared temp folder in %TMPDIR%


cd /D %TMPDIR%


set FINISHED="%TMPDIR%\finished.bat"
echo @echo off > %FINISHED%
echo echo. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo INSTALLATION SUCCESSFULLY FINISHED !!! >> %FINISHED%
echo echo. >> %FINISHED%
echo echo A python script %HOMEDRIVE%%HOMEPATH%\.bitdust\src\bitdust.py is main entry point to run the software. >> %FINISHED%
echo echo You can click on the new icon created on the desktop to open the root application folder. >> %FINISHED%
echo echo Use those shortcuts to control BitDust at any time: >> %FINISHED%
echo echo     START:            execute the main process and/or open the web browser to access the user interface >> %FINISHED%
echo echo     STOP:             stop (or kill) the main BitDust process completely >> %FINISHED%
echo echo     SYNCHRONIZE:      update BitDust sources from the public repository >> %FINISHED%
echo echo     SYNC^^^&RESTART:     update sources and restart the software softly in background >> %FINISHED%
echo echo     DEBUG:            run the program in debug mode so you can watch the full program output >> %FINISHED%
echo echo. >> %FINISHED%
echo echo To be sure you are running the latest version use "SYNCHRONIZE" and "SYNC&RESTART" shortcuts. >> %FINISHED%
echo echo You may want to copy "SYNC^&RESTART" shortcut to Startup folder in the Windows Start menu to start the program during bootup process - jsut to keep it fresh and updated. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo Now executing "START" command and running BitDust software in background mode, this window can be closed now. >> %FINISHED%
echo echo Your web browser will be opened at the moment and you will see the starting page. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo Welcome to the BitDust World !!!. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo. >> %FINISHED%
echo echo. >> %FINISHED%


echo *** Checking wget.exe file
if exist wget0.exe goto WGetDownloaded


set DLOAD_SCRIPT="download.vbs"
echo Option Explicit                                                    >  %DLOAD_SCRIPT%
echo Dim args, http, fileSystem, adoStream, url, target, status         >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set args = Wscript.Arguments                                       >> %DLOAD_SCRIPT%
echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1")              >> %DLOAD_SCRIPT%
echo url = args(0)                                                      >> %DLOAD_SCRIPT%
echo target = args(1)                                                   >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo http.Open "GET", url, False                                        >> %DLOAD_SCRIPT%
echo http.Send                                                          >> %DLOAD_SCRIPT%
echo status = http.Status                                               >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo If status ^<^> 200 Then                                            >> %DLOAD_SCRIPT%
echo    WScript.Echo "FAILED to download: HTTP Status " ^& status       >> %DLOAD_SCRIPT%
echo    WScript.Quit 1                                                  >> %DLOAD_SCRIPT%
echo End If                                                             >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set adoStream = CreateObject("ADODB.Stream")                       >> %DLOAD_SCRIPT%
echo adoStream.Open                                                     >> %DLOAD_SCRIPT%
echo adoStream.Type = 1                                                 >> %DLOAD_SCRIPT%
echo adoStream.Write http.ResponseBody                                  >> %DLOAD_SCRIPT%
echo adoStream.Position = 0                                             >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set fileSystem = CreateObject("Scripting.FileSystemObject")        >> %DLOAD_SCRIPT%
echo If fileSystem.FileExists(target) Then fileSystem.DeleteFile target >> %DLOAD_SCRIPT%
echo adoStream.SaveToFile target                                        >> %DLOAD_SCRIPT%
echo adoStream.Close                                                    >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%


echo *** Downloading wget.exe
cscript //Nologo %DLOAD_SCRIPT% https://eternallybored.org/misc/wget/1.19.4/32/wget.exe wget0.exe
:WGetDownloaded


if exist unzip.exe goto UnZIPDownloaded 
echo *** Downloading unzip.exe
wget0.exe  http://www2.cs.uidaho.edu/~jeffery/win32/unzip.exe --no-check-certificate 
:UnZIPDownloaded


set EXTRACT_SCRIPT="msiextract.vbs"
echo Set args = Wscript.Arguments > %EXTRACT_SCRIPT%
echo Set objShell = CreateObject("Wscript.Shell") >> %EXTRACT_SCRIPT%
echo objCommand ^= ^"msiexec /a ^" ^& Chr(34) ^& args(0) ^& Chr(34) ^& ^" /qn /quiet TargetDir^=^" ^& Chr(34) ^& args(1) ^& Chr(34) >> %EXTRACT_SCRIPT%
echo objShell.Run objCommand, 1, true >> %EXTRACT_SCRIPT%


set SUBSTITUTE="substitute.vbs"
echo strFileName ^= Wscript.Arguments(0) > %SUBSTITUTE%
echo strOldText ^= Wscript.Arguments(1) >> %SUBSTITUTE%
echo strNewText ^= Wscript.Arguments(2) >> %SUBSTITUTE%
echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> %SUBSTITUTE%
echo Set objFile = objFSO.OpenTextFile(strFileName, 1) >> %SUBSTITUTE%
echo strText = objFile.ReadAll >> %SUBSTITUTE%
echo objFile.Close >> %SUBSTITUTE%
echo strNewText = Replace(strText, strOldText, strNewText) >> %SUBSTITUTE%
echo Set objFile = objFSO.OpenTextFile(strFileName, 2) >> %SUBSTITUTE%
echo objFile.WriteLine strNewText >> %SUBSTITUTE%
echo objFile.Close >> %SUBSTITUTE%


rem echo *** Stopping Python instances
rem taskkill  /IM BitDustNode.exe /F /T


echo *** Checking for python binaries in the destination folder %BITDUST_HOME%\python\
if exist %BITDUST_HOME%\python\python.exe goto PythonInstalled


if exist python-2.7.9.msi goto PythonDownloaded 
echo *** Downloading python-2.7.9.msi
wget0.exe  https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi --no-check-certificate 
:PythonDownloaded
echo *** Extracting python-2.7.9.msi to %BITDUST_HOME%\python
if not exist %BITDUST_HOME%\python mkdir "%BITDUST_HOME%\python"
cscript //Nologo %EXTRACT_SCRIPT% python-2.7.9.msi "%BITDUST_HOME%\python"
echo *** Verifying Python binaries
if exist %BITDUST_HOME%\python\python.exe goto PythonInstalled
echo *** Python installation to %BITDUST_HOME%\python was failed!
exit /b %errorlevel%
:PythonInstalled


echo *** Checking Python version
%BITDUST_HOME%\python\python.exe --version
if errorlevel 0 goto ContinueInstall
echo *** Python installation to %BITDUST_HOME%\python is corrupted!
exit /b %errorlevel%
:ContinueInstall


echo *** Checking for pip installed
if exist %BITDUST_HOME%\python\Scripts\pip.exe goto PipInstalled
echo *** Installing pip
del /F /Q get-pip.py
wget0.exe https://bootstrap.pypa.io/get-pip.py --no-check-certificate
%BITDUST_HOME%\python\python.exe get-pip.py
if %errorlevel% neq 0 goto DEPLOY_ERROR
:PipInstalled


echo *** Checking for git binaries in the destination folder
if exist %BITDUST_HOME%\git\bin\git.exe goto GitInstalled
if exist Git-2.10.0-32-bit.exe goto GitDownloaded 
echo *** Downloading Git-2.10.0-32-bit.exe
wget0.exe https://github.com/git-for-windows/git/releases/download/v2.10.0.windows.1/Git-2.10.0-32-bit.exe --no-check-certificate
if %errorlevel% neq 0 goto DEPLOY_ERROR
:GitDownloaded
echo *** Extracting Git-2.10.0-32-bit.exe to %TMPDIR%\git_temp
Git-2.10.0-32-bit.exe /DIR="%BITDUST_HOME%\git" /NOICONS /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /COMPONENTS=""
if %errorlevel% neq 0 goto DEPLOY_ERROR
:GitExtracted
if %errorlevel% neq 0 goto DEPLOY_ERROR
:GitInstalled


echo *** Checking for pywin32 installed
if exist %BITDUST_HOME%\python\Lib\site-packages\win32\win32api.pyd goto PyWin32Installed
echo *** Installing pywin32
%BITDUST_HOME%\python\Scripts\pip.exe install pywin32
:PyWin32Installed


echo *** Checking for PyCrypto installed
if exist %BITDUST_HOME%\python\Lib\site-packages\Crypto\__init__.py goto PyCryptoInstalled
if exist pycrypto-2.6.win32-py2.7.exe  goto PyCryptoDownloaded 
echo *** Downloading pycrypto-2.6.win32-py2.7.exe
wget0.exe  "http://www.voidspace.org.uk/downloads/pycrypto26/pycrypto-2.6.win32-py2.7.exe" --no-check-certificate 
if %errorlevel% neq 0 goto DEPLOY_ERROR
:PyCryptoDownloaded
echo *** Installing pycrypto-2.6.win32-py2.7.exe
unzip.exe -o -q pycrypto-2.6.win32-py2.7.exe -d pycrypto
xcopy pycrypto\PLATLIB\*.* %BITDUST_HOME%\python\Lib\site-packages /E /I /Q /Y
:PyCryptoInstalled


echo *** Checking for Incremental installed
if exist %BITDUST_HOME%\python\Lib\site-packages\incremental\__init__.py goto IncrementalInstalled
if exist incremental-17.5.0-py2.py3-none-any.whl  goto IncrementalDownloaded 
echo *** Downloading incremental-17.5.0-py2.py3-none-any.whl
wget0.exe  "https://files.pythonhosted.org/packages/f5/1d/c98a587dc06e107115cf4a58b49de20b19222c83d75335a192052af4c4b7/incremental-17.5.0-py2.py3-none-any.whl" --no-check-certificate 
if %errorlevel% neq 0 goto DEPLOY_ERROR
:IncrementalDownloaded
echo *** Installing incremental-17.5.0-py2.py3-none-any.whl
%BITDUST_HOME%\python\Scripts\pip.exe install incremental-17.5.0-py2.py3-none-any.whl
:IncrementalInstalled


echo *** Checking for Twisted installed
if exist %BITDUST_HOME%\python\Lib\site-packages\twisted\__init__.py goto TwistedInstalled
if exist Twisted-17.9.0-cp27-cp27m-win32.whl  goto TwistedDownloaded 
echo *** Downloading Twisted-17.9.0-cp27-cp27m-win32.whl
wget0.exe "https://github.com/zerodhatech/python-wheels/raw/master/Twisted-17.9.0-cp27-cp27m-win32.whl" --no-check-certificate 
if %errorlevel% neq 0 goto DEPLOY_ERROR
:TwistedDownloaded
echo *** Installing Twisted-17.9.0-cp27-cp27m-win32.whl
%BITDUST_HOME%\python\Scripts\pip.exe install Twisted-17.9.0-cp27-cp27m-win32.whl
:TwistedInstalled


echo *** Prepare sources folder
if not exist %BITDUST_HOME%\src mkdir %BITDUST_HOME%\src


cd /D %BITDUST_HOME%\src


if exist %BITDUST_HOME%\src\bitdust.py goto SourcesExist
echo *** Downloading BitDust software using "git clone" from GitHub devel repository
%BITDUST_HOME%\git\bin\git.exe clone -q --depth 1 https://github.com/bitdust-io/devel.git .
if %errorlevel% neq 0 goto DEPLOY_ERROR
:SourcesExist


echo *** Running command "git clean" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe clean -q -d -f -x .
echo *** Running command "git reset" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe reset --hard origin/master
echo *** Running command "git pull" in BitDust repository
%BITDUST_HOME%\git\bin\git.exe pull


echo *** Checking BitDust virtual environment
if exist %BITDUST_HOME%\venv goto VenvExist
echo *** Checking/Installing virtualenv
%BITDUST_HOME%\python\Scripts\pip.exe install virtualenv
if %errorlevel% neq 0 goto DEPLOY_ERROR
echo *** Deploy BitDust virtual environment
%BITDUST_HOME%\python\python.exe bitdust.py install
if %errorlevel% neq 0 goto DEPLOY_ERROR
:VenvExist


set BITDUST_NODE=%BITDUST_HOME%\venv\Scripts\BitDustNode.exe
echo *** Make sure Python "alias" created in %BITDUST_NODE%
if exist %BITDUST_NODE% goto BitDustNodeExeExist
copy /B /Y %BITDUST_HOME%\venv\Scripts\python.exe %BITDUST_NODE%
echo *** Created %BITDUST_NODE% "alias" from %BITDUST_HOME%\venv\Scripts\python.exe
:BitDustNodeExeExist


cd /D %BITDUST_HOME%\

if exist %BITDUST_HOME%\ui\index.html goto UISourcesExist
echo *** Downloading BitDust UI using "git clone" from GitHub devel repository
%BITDUST_HOME%\git\bin\git.exe clone -q --depth 1 https://github.com/bitdust-io/web.git ui
if %errorlevel% neq 0 goto DEPLOY_ERROR
:UISourcesExist


cd /D %BITDUST_HOME%\ui\
echo *** Running command "git clean" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe clean -q -d -f -x .
echo *** Running command "git reset" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe reset --hard origin/master
echo *** Running command "git pull" in BitDust UI repository
%BITDUST_HOME%\git\bin\git.exe pull


goto DEPLOY_SUCCESS

:DEPLOY_ERROR
echo DEPLOYMENT FAILED
echo.
exit /b %errorlevel%


:DEPLOY_SUCCESS
echo *** Starting BitDust ...
cd /D "%BITDUST_HOME%"
echo "%BITDUST_NODE%" "%BITDUST_HOME%\src\bitdust.py daemon"
%BITDUST_NODE% %BITDUST_HOME%\src\bitdust.py daemon
cd /D "%CURRENT_PATH%"
echo SUCCESS
echo.

