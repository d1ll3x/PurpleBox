SET PowerShellScriptPath=%~dp0
SET LOGFILE=batch.log

:: Redirect the entire output of the batch file to the log file
CALL :LOG > %LOGFILE% 2>&1
exit /B

:LOG
:: Install Atomic Red Team
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%install-redteam.ps1'";

:: Install Sysinternals Suite
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%install-sysinternals.ps1'";

:: Install Winlogbeat agent
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%install-winlogbeat.ps1'";