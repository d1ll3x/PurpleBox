# Purpose: Installs the Winlogbeat agent to enable log forwarding
# Also configures winlogbeat.yml to connect to the ELK stack

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Winlogbeat agent..."
$winlogbeatDir = "C:\Tools\Winlogbeat"
If(!(test-path $winlogbeatDir)) {
  New-Item -ItemType Directory -Force -Path $winlogbeatDir
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Winlogbeat directory exists, no need to re-install. Exiting."
  exit
}

# Be aware to use the desired winlogbeat version
$winlogbeatPath = "$winlogbeatDir\winlogbeat.msi"
$winlogbeatAgentVersion = "8.13.4"

# Download the winlogbeat msi from elastic
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading winlogbeat.msi..."
Try { 
  $url = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-$winlogbeatAgentVersion-windows-x86_64.msi"    
  (New-Object System.Net.WebClient).DownloadFile($url, $winlogbeatPath)
} Catch { 
  Write-Host "HTTPS connection failed. Please check your network connection or the URL."
}

# Install Winlogbeat
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Install Winlogbeat agent..."
Start-Process msiexec.exe -ArgumentList "/i `"$winlogbeatPath`" INSTALLDIR=`"$winlogbeatDir`" /quiet /norestart" -Wait
& $winlogbeatDir\install-service-winlogbeat.ps1

# Copy winlogbeat.yml file from the host machine and start Winlogbeat
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Starting Winlogbeat agent..."
$winlogbeatConfigPath = "\\host.lan\\Data\\winlogbeat.yml"
Copy-Item -Path $winlogbeatConfigPath -Destination $winlogbeatDir
Start-Process $winlogbeatDir\\winlogbeat.exe -ArgumentList "setup -e"
Start-Service winlogbeat