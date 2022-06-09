@echo off
REM Things to uninstall: Anaconda, Apache CouchDB, Git, NodeJS, Pandoc, PASTA, Python, Python Launcher 
REM Adopt paths: remove python path; reduce PATH
REM Remove: pasta_dir and temp_download
REM print content line. No " '
echo Installer for PASTA database on Windows Systems
echo - Twice, in the middle of the process, you have to restart the commandline and this script. You will be notified when.
echo - You will be asked to install packages, please answer yes. Sometimes, the options are choosen automatically and you are not asked.
echo - If you don't want to install into 'My Documents'. First install into 'My Documents' and after installation follow 
echo.   instructions, see next item.
echo - If you have problems, visit https://pasta-eln.github.io/troubleshooting.html#problems-during-installation
echo - Default choices are accepted by return: [Y/n]->yes; [default]->default

REM print empty line
echo.
REM ask for user input
echo One empty (for safety) directory is required for source code and one for the research data.
set softwareDir=
set pastaDir=
set /p softwareDir="Which subdirectory of 'My Documents' should the software be installed to [e.g. pasta_source]? "
set /p pastaDir="Which subdirectory of 'My Documents' should the research data be saved in [e.g. pasta_data]? "
REM check for empty line
if not defined softwareDir (set softwareDir=pasta_source)
if not defined pastaDir (set pastaDir=pasta_data)
set softwareDir=Documents\%softwareDir%
set pastaDir=Documents\%pastaDir%
set downloadDir=%HOMEDRIVE%%HOMEPATH%\Documents\tempDownload
mkdir %downloadDir%
mkdir %HOMEDRIVE%%HOMEPATH%\%pastaDir%
echo.
REM Wait for user feedback: pause
REM pause

REM Install Python, Set PAPTH, Set PYTHONPATH, Install some python-packages
echo Ensure that the ordinary python is installed
echo Anaconda is not supported since it uses the
echo.  conda-framework which makes it difficult to
echo.  (1) install custom packages, (2) run your own
echo.  python programs from windows. It basically
echo.  creates a bubble, which is difficult to
echo.  penetrate. If you have it installed, stop here,
echo.  uninstall Anaconda and restart this script.
pause
REM echo with preceeding space
REM chain commands, use & at beginning of new line
FOR /F "tokens=* USEBACKQ" %%F in (`python --version`) do (set var=%%F)
echo %var% | findstr /C:"Python 3" 1>nul
if errorlevel==1 (echo.  Download python now) else (echo.  Python is installed in version 3.& goto end_python)
if not exist %downloadDir%/python-3.9.13-amd64.exe (bitsadmin.exe /TRANSFER python3 https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe  %downloadDir%/python-3.9.13-amd64.exe)
start /WAIT %downloadDir%/python-3.9.13-amd64.exe  /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
echo Installed Python
:end_python
echo.

echo Set environment variables: PATH
echo %PATH% | findstr "Python">nul
REM echo with preceeding space
REM chain commands, use & at beginning of new line
if errorlevel==1 (echo.  setting path now^
  & echo CANNOT DO THIS AUTOMATICALLY. Please do manually:^
  & echo.  Adopt the Environment Variables. Click start-button and type^
  & echo.  "Enviro" and select "Edit environmenal variables for your account"^
  & echo.  from the search results. In the window for USER-VARIABLES, click^
  & echo.  on "Path" and "Edit...". Click new three times and enter each time^
  & echo.  with copy [select+Return] - paste. If content is already inside, skip it.^
  & echo.  - C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python39^
  & echo.  - C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python39\Scripts^
  & echo.  - %HOMEDRIVE%%HOMEPATH%\%softwareDir%\Python^
  & echo.  Restart cmd and install.bat^
  & echo.^
  & pause
  ) else (echo.  no need to set path variable as it seems to be correct)
echo.
REM this does not work in a reproducable fashion
REM  setx PATH "%PATH%;C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python39;C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python39\Scripts;%softwareDir%\main"^

REM set PYTHONPATH already. Possible restarts will take this already into account
echo Set environment variables: PYTHONPATH
setx PYTHONPATH "%HOMEDRIVE%%HOMEPATH%\Documents\%softwareDir%"
echo.


echo Verify that python works
FOR /F "tokens=* USEBACKQ" %%F in (`python --version`) do (set var=%%F)
echo Output: %var%
echo If python does not work, updates were not registered yet.
echo.   - STOP (ctrl-c and Y) script here and close cmd.exe window
echo.   - START new cmd.exe window
echo.   - restart install.bat
pause

echo Install basic python packages for windows
pip.exe install win-unicode-console pywin32 pywin32-ctypes >nul
pip.exe install matplotlib pandas wget spyder >nul
echo.

echo Test if python is fully working: plot a sine-curve
set var=void void
set /p var="  Skip sine-curve [y/N] "
echo %var% | findstr "y">nul
if errorlevel==1 (python.exe -c "import numpy as np;x = np.linspace(0,2*np.pi);y = np.sin(x);import matplotlib.pyplot as plt;plt.plot(x,y);plt.show()")
echo.
echo If error occured with numpy: there is some issue with Windows
echo.  and some basic fuction. Click start button and type: cmd and
echo.  commandline tool. Enter "pip install numpy==1.19.3" in it.
echo.
echo Spyder is a helpful Tool for writing python code. Search for
echo.  "spyder" on your hard-disk and pin it to start.
echo.
echo If you only care about python, stop here.
echo.
pause


@REM echo Install pandoc
@REM set var=void void
@REM FOR /F "tokens=* USEBACKQ" %%F in (`where pandoc`) do (set var=%%F)
@REM echo %var% | findstr "void">nul
@REM if errorlevel==1 (echo. Pandoc is installed & goto end_pandoc)
@REM echo.  Download Pandoc now
@REM if not exist %downloadDir%\pandoc-2.11.3.2-windows-x86_64.msi (python.exe -m wget -o %downloadDir% https://github.com/jgm/pandoc/releases/download/2.11.3.2/pandoc-2.11.3.2-windows-x86_64.msi)
@REM start /WAIT %downloadDir%\pandoc-2.11.3.2-windows-x86_64.msi
@REM :end_pandoc
@REM echo.


REM START WITH GIT, Git-annex, git-credentials
echo Install git
set var=void void
FOR /F "tokens=* USEBACKQ" %%F in (`where git`) do (set var=%%F)
echo %var% | findstr "void">nul
if errorlevel==1 (echo. Git is installed) else (winget install --id Git.Git -e --source winget)
echo.
echo Install git-annex
set var=void void
FOR /F "tokens=* USEBACKQ" %%F in (`where git-annex`) do (set var=%%F)
echo %var% | findstr "void">nul
if errorlevel==1 (echo. Git-annex is installed) else (^
  echo.  Download git-annex now^
  & python.exe -m wget -o %downloadDir% https://downloads.kitenet.net/git-annex/windows/7/current/git-annex-installer.exe^
  & start /WAIT %downloadDir%\git-annex-installer.exe^
  )
echo.

echo Verify that git works
FOR /F "tokens=* USEBACKQ" %%F in (`git --version`) do (set var=%%F)
echo Output: %var%
echo If git does not work, updates were not registered yet.
echo.   - STOP (ctrl-c and Y) script here and close cmd.exe window
echo.   - START new cmd.exe window
echo.   - restart install.bat
pause

echo Check git credentials
set var=void void
FOR /F "tokens=* USEBACKQ" %%F in (`git config --global --get user.name`) do (set var=%%F)
echo %var% | findstr "void">nul
if errorlevel==1 (echo.  git-username is set & goto end_user_name)
echo.  set git-username credentials
set /p var="  What is your name? "
git config --global --add user.name "%var%"
:end_user_name
set var=void void
FOR /F "tokens=* USEBACKQ" %%F in (`git config --global --get user.email`) do (set var=%%F)
echo %var% | findstr "void">nul
if errorlevel==1 (echo.  git-email is set & goto end_git_email)
echo.  set git-email credentials
set /p var="  What is your email address? "
git config --global --add user.email "%var%"
:end_git_email
echo.


REM Copying PASTA from github
echo Copying PASTA from github
git clone https://github.com/PASTA-ELN/desktop.git %HOMEDRIVE%%HOMEPATH%\%softwareDir%
cd %HOMEDRIVE%%HOMEPATH%\%softwareDir%
git clone https://github.com/PASTA-ELN/Python.git
echo.


REM Install python dependencies
echo Install python dependencies
cd Python
pip3 install -r requirements.txt >nul
echo.


REM Start with couchDB
REM the silent install https://docs.couchdb.com/en/3.1.2/install/windows.html#silent-install would be great
REM   if I do it, I cannot connect to it
REM   the user is not asked (change into admin mode) and hence the installation does not start
REM   solution unclear
echo Install couchDB
echo.  - If Windows warns you, go to **more information** and **run anyway**. 
echo.  - Accept the default setting and the license
echo.  - As user name enter 'admin'. Remember password that you enter. Validate the entries.
echo.
if exist "%ProgramFiles%\Apache CouchDB\bin" (goto end_couchdb)
if not exist %downloadDir%\apache-couchdb-3.1.1.msi (python.exe -m wget -o %downloadDir% https://couchdb.neighbourhood.ie/downloads/3.1.1/win/apache-couchdb-3.1.1.msi)
start /wait %downloadDir%\apache-couchdb-3.1.1.msi
:end_couchdb
set /p CDB_PASSW="Which password did you enter? "
cls

REM Create PASTA configuration file .pastaELN.json in home directory
echo Create PASTA configuration file .pastaELN.json in home directory
cd ..
python makeConfigFile.py %softwareDir% %pastaDir% %CDB_PASSW%
echo.


REM Run a two short tests of the python backend
echo Run a very short (5sec) test of the python backend
cd Python
python pastaELN.py test
echo.
python pastaELN.py extractorScan
echo.
echo Run a short (20-80sec) test of the python backend
python Tests\verifyInstallation.py
echo.


echo Graphical user interface GUI
echo ==========================================================
%HOMEDRIVE%%HOMEPATH%\%softwareDir%\PASTA-Setup-win.exe
echo To start PASTA: there are desktop icon
echo.
echo It is good to start with Projects, then Samples and Procedures and finally
echo Measurements.
echo.
echo MAKE SURE, you wrote down PASSWORD FOR SAFEKEEPING: %CDB_PASSW%
echo Currently, the configuration ~/.pastaELN.json is unscrambled
echo.   use PASTA for some time, then run 'pastaELN.py scramble' to scramble them
echo.   after some more time, delete the backup '~/.pastaELN_BAK.json'
echo ==========================================================
echo.

pause
REM After update, GUI has to be uninstalled and reinstalled
REM electron readme: not installed anymore, install nodejs (no tools like cocolay required), npm install, npm start

REM winget install OpenJS.NodeJS.LTS
REM mklink %HOMEDRIVE%%HOMEPATH%\Desktop\PASTA_ELN %HOMEDRIVE%%HOMEPATH%\%softwareDir%\PASTA-Setup-win.exe

