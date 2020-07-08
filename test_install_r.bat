:: @echo off
:: set download_url=%1
:: set r_version=%2
:: set download_path=%3

:: set r_version=%1

:: echo %r_version%
:: PAUSE

:: The following code was borrow & modified from https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing
@echo off
setlocal enableDelayedExpansion

set "options=-option1:/ -option2:"" -option3:"three word default""

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

::set -

:: To get the value of a single parameter, just remember to include the `-`
:: echo The value of -option1 is: !-option1!