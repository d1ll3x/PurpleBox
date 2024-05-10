:: Change execution policy
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force"

:: Install dependencies
powershell -Command "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force"

:: Download sysmon and winlogbeat
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/Sysmon.zip', 'sysmon.zip')"
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-8.12.2-windows-x86_64.zip', 'winlogbeat-8.12.2-windows-x86_64.zip')"

:: Unzip files
powershell -Command "Expand-Archive -Path .\sysmon.zip -DestinationPath . -Force"
powershell -Command "Expand-Archive -Path .\winlogbeat-8.12.2-windows-x86_64.zip -DestinationPath 'C:\\Program Files' -Force"

:: Install sysmon
.\Sysmon.exe -i -accepteula -l -n

:: Install winlogbeat
powershell -Command "Rename-Item -Path 'C:\\Program Files\\winlogbeat-8.12.2-windows-x86_64' -NewName 'C:\\Program Files\\winlogbeat'"
powershell -Command "cd 'C:\\Program Files\\winlogbeat'; .\\install-service-winlogbeat.ps1"

:: Inject winlogbeat.yml configuration file
powershell -Command "Copy-Item -Path '\\host.lan\\Data\\winlogbeat.yml' -Destination 'C:\\Program Files\\winlogbeat'"

:: Start winlogbeat
powershell -Command "Start-Service winlogbeat"

:: Download and install Atomic Red Team
powershell -Command "IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing); Install-AtomicRedTeam -getAtomics -Force"
powershell -Command "Install-Module -Name invoke-atomicredteam,powershell-yaml -Scope CurrentUser -Force"