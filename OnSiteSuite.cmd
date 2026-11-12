@echo off
setlocal
where pwsh.exe >nul 2>&1
if errorlevel 1 (
  1>&2 echo Erro: PowerShell 7 ^(pwsh.exe^) nao encontrado no PATH.
  exit /b 3
)
if not defined ONS_USB_TERMINAL set "ONS_USB_TERMINAL=CMD"
pwsh.exe -NoLogo -NoProfile -File "%~dp0OnSiteSuite.ps1" %*
exit /b %ERRORLEVEL%
