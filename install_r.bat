:: The following code was borrow & modified from https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing
@echo off
for /f "tokens=3*" %%d IN ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') do (set documents_path=%%d %%e)
setlocal enableDelayedExpansion

set "options=-r_version:"" -root_url:"https://cloud.r-project.org/bin/windows/base/old" -download_url:"" -download_path:"" -keep_installer:"true" -install_rtools:"true" -options:"/SILENT""

for %%O in (%options%) do for /f "tokens=1,* delims=:" %%A in ("%%O") do set "%%A=%%~B"
:loop
if not "%~1"=="" (
  set "test=!options:*%~1:=! "
  if "!test!"=="!options! " (
      echo Error: Invalid option %~1
      GOTO:EOF
  ) else if "!test:~0,1!"==" " (
      set "%~1=1"
  ) else (
      setlocal disableDelayedExpansion
      set "val=%~2"
      call :escapeVal
      setlocal enableDelayedExpansion
      for /f delims^=^ eol^= %%A in ("!val!") do endlocal&endlocal&set "%~1=%%A" !
      shift /1
  )
  shift /1
  goto :loop
)
goto :endArgs
:escapeVal
set "val=%val:^=^^%"
set "val=%val:!=^!%"
exit /b
:endArgs

:: set -

:: To get the value of a single parameter, just remember to include the `-`
:: echo The value of -r_version is: !-r_version!

:: Set parameters
set r_version="!-r_version!"
set r_version=%r_version:"=%
set root_url=!-root_url!
set download_url=!-download_url!
set download_path=!-download_path!
if "!download_path!"=="" (
  set download_path=!USERPROFILE!\Downloads
)
set keep_installer=!-keep_installer!
set install_rtools=!-install_rtools!
set options=!-options!

:: Check -r_version
if not "!r_version!"=="" (
  echo !r_version!|findstr /r "^[0-9]\.[0-9]\.[0-9]$" >nul 2>&1 || (echo Invalid 'r_version'^^! Please specify a valid 'r_version')
) else (
  echo 'r_version' missing^^! Please specify a valid 'r_version'
  GOTO:EOF
)

:: Check -download_path
if not exist !download_path! (
  echo '!download_path!' not exist! Please specify a valid 'download_path'
  GOTO:EOF
)

:: Set R installer download URL
if "!download_url!"=="" (
  set download_url=%root_url%/%r_version%/R-%r_version%-win.exe
)

:: Check if R installed
set r_exist="false"
reg query "HKEY_CURRENT_USER\Software\R-core\R" >nul 2>nul
if !errorlevel!==0 (
  for /f "tokens=3* usebackq" %%a in (`reg query "HKEY_CURRENT_USER\Software\R-core\R" /s /v InstallPath^| find "!r_version!"`) do (set r_exist="true")
) else (
  cmd /c "exit /b 0"
)
if !r_exist!=="false" (
  reg query "HKEY_LOCAL_MACHINE\SOFTWARE\R-core\R" >nul 2>nul
  if !errorlevel!==0 (
    for /f "tokens=3* usebackq" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\R-core\R" /s /v InstallPath^| find "!r_version!"`) do (set r_exist="true")
  ) else (
    cmd /c "exit /b 0"
  )
)
if !r_exist!=="true" (
  echo R-!r_version! already installed
  GOTO INST_RTOOLS
) 

:: Download R installer for Windows using BITSadmin
for %%F in (!download_url!) do set file_name=%%~nxF
bitsadmin /transfer download_r /download /priority NORMAL !download_url! "!download_path!\!file_name!"

:: Install R silently, give meaningful message if got issues, eg admin right,..
"!download_path!\!file_name!" !options!
if !keep_installer!=="false" (
  echo Cleaning up R installer...
  del "!download_path!\!file_name!" /s /f /q
)
echo R-!r_version! successfully installed!

:INST_RTOOLS
  :: Check if Rtools exist
  echo Check if Rtools installed...
  set rtools_version_reg=!r_version:~0,3!
  set rtools_version=!rtools_version_reg:.=!
  if !rtools_version!==36 (
    set rtools_version=35
    set rtools_version_reg=3.5
  )
  :: Check if Rtools installed
  set rtools_exist="false"
  reg query "HKEY_CURRENT_USER\Software\R-core\Rtools" >nul 2>nul
  if !errorlevel!==0 (
    for /f "tokens=3* usebackq" %%a in (`reg query "HKEY_CURRENT_USER\Software\R-core\Rtools" /s^| find "!rtools_version_reg!"`) do (set rtools_exist="true")
  ) else (
    cmd /c "exit /b 0"
  )
  if !rtools_exist!=="false" (
    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\R-core\Rtools" >nul 2>nul
    if !errorlevel!==0 (
       for /f "tokens=3* usebackq" %%a in (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\R-core\Rtools" /s^| find "!rtools_version_reg!"`) do (set rtools_exist="true")
    ) else (
      cmd /c "exit /b 0"
    )
  )
  :: If install_rtools=="false", skip Rtools
  if not !install_rtools!=="false" (
    if !rtools_exist!=="false" (
      if !rtools_version!==40 (
        set rtools_url=https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe
      ) else (
        set rtools_url=https://cran.r-project.org/bin/windows/Rtools/Rtools!rtools_version!.exe
      )
      for %%F in (!rtools_url!) do set rtools_file_name=%%~nxF
      bitsadmin /transfer download_rtools /download /priority NORMAL !rtools_url! "!download_path!\!rtools_file_name!"
      
      :: Install Rtools
      "!download_path!\!rtools_file_name!" /SILENT /DIR="!documents_path!\Rtools!rtools_version!"
      if !keep_installer!=="false" (
        echo Cleaning up Rtools installer...
        del "!download_path!\!rtools_file_name!" /s /f /q
      )
      :: Add Rtools dir to PATH
      for /f "tokens=3*" %%d IN ('reg query HKEY_CURRENT_USER\Environment /v Path') do (set path=%%d %%e)
      if !rtools_version!==40 (
        C:\Windows\System32\setx.exe PATH "!path!;!documents_path!\Rtools!rtools_version!\usr\bin"  
      ) else (
        C:\Windows\System32\setx.exe PATH "!path!;!documents_path!\Rtools!rtools_version!\bin"
      )
      echo Rtools!rtools_version! successfully installed!
    ) else (
      echo Rtools!rtools_version! already installed
    )
  ) else (
    if !rtools_exist!=="false" (
      echo Warning: Rtools!rtools_version! not installed. Consider to install Rtools before proceed
    )
  )