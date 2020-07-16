:: The following code was borrow & modified from https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing
@echo off
setlocal enableDelayedExpansion

set "options=-r_version:"" -root_url:"https://cloud.r-project.org/bin/windows/base/old" -download_url:"" -download_path:%USERPROFILE%\Downloads -keep_installer:"true" -options:"/SILENT""

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
set r_version=!-r_version!
set root_url=!-root_url!
set download_url=!-download_url!
set download_path=!-download_path!
set keep_installer=!-keep_installer!
set options=!-options!

if "%download_url%"=="" (
  :: Check -r_version
  if not "%r_version%"=="" (
    ::  && (echo The value of -r_version is: !-r_version!)
    echo %r_version%|findstr /r "^[0-9]\.[0-9]\.[0-9]$" >nul 2>&1 && (set download_url=%root_url%/%r_version%/R-%r_version%-win.exe) || (echo Invalid 'r_version'^^! Please specify a valid 'r_version')
  ) else (
    echo 'r_version' missing^^! Please specify a valid 'r_version'
    GOTO:EOF
  )
)

:: Download R installer for Windows using BITSadmin
if not exist %download_path% (
  echo '%download_path%' not exist! Please specify a valid 'download_path'
  GOTO:EOF
)
for %%F in (%download_url%) do set file_name=%%~nxF
bitsadmin /transfer download_installer /download /priority NORMAL %download_url% "%download_path%\%file_name%"

:: Install R silently, give meaningful message if got issues, eg admin right,..
"%download_path%\%file_name%" %options%
if %keep_installer%=="false" (
  echo Cleaning up installer...
  del "%download_path%\%file_name%" /s /f /q
)
echo Installation completed!