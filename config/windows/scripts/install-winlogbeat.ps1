# Purpose: Installs the Winlogbeat agent to enable log forwarding
# Also configures winlogbeat.yml to connect to the ELK stack

# Be aware to use the desired winlogbeat version
$winlogbeatDir = "C:\Tools\Winlogbeat"
$winlogbeatDownload = "$winlogbeatDir\winlogbeat.msi"
$winlogbeatAgentVersion = "8.13.4"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Winlogbeat agent..."
If(!(test-path $winlogbeatDir)) {
  New-Item -ItemType Directory -Force -Path $winlogbeatDir
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Winlogbeat directory exists, no need to re-install. Exiting."
  exit
}

# Download the winlogbeat msi from elastic
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading winlogbeat.msi..."
Try { 
  $url = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-$winlogbeatAgentVersion-windows-x86_64.msi"    
  (New-Object System.Net.WebClient).DownloadFile($url, $winlogbeatDownload)
} Catch { 
  Write-Host "HTTPS connection failed. Please check your network connection or the URL."
}

# Install Winlogbeat
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Winlogbeat agent..."
Start-Process msiexec.exe -ArgumentList "/i `"$winlogbeatDownload`" INSTALLDIR=`"$winlogbeatDir`" /quiet /norestart" -Wait

# Copy winlogbeat.yml file from the host machine
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Copying winlogbeat.yml config..."
$winlogbeatConfigPath = "\\host.lan\\Data\\winlogbeat.yml"
Copy-Item -Path $winlogbeatConfigPath -Destination $winlogbeatDir

# Start Winlogbeat
Set-Location -Path "$winlogbeatDir"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if the winlogbeat service exists and recreate if it does..."

if (Get-Service winlogbeat -ErrorAction SilentlyContinue) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Deleting winlogbeat service..."
  $service = Get-WmiObject -Class Win32_Service -Filter "name='winlogbeat'"
  $service.StopService()
  Start-Sleep -Seconds 5
  $service.delete()

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating and starting winlogbeat service..."
  New-Service -Name winlogbeat -DisplayName winlogbeat -BinaryPathName "`"$winlogbeatDir\\winlogbeat.exe`" -c `"$winlogbeatDir\\winlogbeat.yml`" -path.home `"$winlogbeatDir`" -path.data `"$winlogbeatDir`""
  Get-Service -Name winlogbeat | Start-Service  
}
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Winlogbeat service does not exist..."
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating and starting winlogbeat service..."
New-Service -Name winlogbeat -DisplayName winlogbeat -BinaryPathName "`"$winlogbeatDir\\winlogbeat.exe`" -c `"$winlogbeatDir\\winlogbeat.yml`" -path.home `"$winlogbeatDir`" -path.data `"$winlogbeatDir`""
Get-Service -Name winlogbeat | Start-Service