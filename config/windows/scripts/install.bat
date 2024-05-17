SET PowerShellScriptPath=%~dp0

:: Install Atomic Red Team
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%install-redteam.ps1'";

:: Install Sysinternals Suite
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%install-sysinternals.ps1'";

:: Install Winlogbeat agent
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%install-winlogbeat.ps1'";