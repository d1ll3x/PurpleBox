# Purpose: Installs the Winlogbeat agent to enable log forwarding
# Also configures winlogbeat.yml to connect to the ELK stack

Set-ExecutionPolicy Bypass -Scope Process -Force;
$ErrorActionPreference = "Stop"

# Be aware to use the desired winlogbeat version
$winlogbeatPath = "C:\ProgramData\Elastic\Winlogbeat"
$winlogbeatAgentVersion = "8.13.4"
$package = "winlogbeat-$winlogbeatAgentVersion-windows-x86_64"

Write-Host "$('[{0:HH:mm}]' -f Yellow (Get-Date)) Creating Winlogbeat directory..."
New-Item -ItemType Directory -Force -Path $winlogbeatPath

# Download the Winlogbeat package from elastic
Write-Host "$('[{0:HH:mm}]' -f Yellow (Get-Date)) Downloading winlogbeat zip..."
Try { 
  $zip = "$package.zip"
  $url = "https://artifacts.elastic.co/downloads/beats/winlogbeat/$zip"
  $tempPath = "C:\ProgramData\Elastic\"
  Invoke-WebRequest $url -OutFile $tempPath\$zip
  Write-Host "$('[{0:HH:mm}]' -f Green (Get-Date)) Success!"
}
Catch {
    Write-Host "$('[{0:HH:mm}]' -f Red (Get-Date)) An error occured: $_"
}

# Install Winlogbeat
Write-Host "$('[{0:HH:mm}]' -f Yellow (Get-Date)) Installing Winlogbeat agent..."
Try {
  Expand-Archive -Path $tempPath/$zip -DestinationPath $tempPath
  Move-Item -Path "$tempPath\$package\*" -Destination $winlogbeatPath -Force
  Remove-Item -Path $tempPath/$zip -Recurse -Force
  Remove-Item -Path $tempPath/$package -Recurse -Force
  Set-Location -Path "$winlogbeatPath"
  .\install-service-winlogbeat.ps1
  Write-Host "$('[{0:HH:mm}]' -f Green (Get-Date)) Success!"
}
Catch {
  Write-Host "$('[{0:HH:mm}]' -f Red (Get-Date)) An error occured: $_"
}

# Download Winlogbeat.yml
Write-Host "$('[{0:HH:mm}]' -f Yellow (Get-Date)) Downloading winlogbeat.yml..."
Try {
  Invoke-WebRequest 'https://raw.githubusercontent.com/d1ll3x/AtomicSandbox/main/sandbox/config/winlogbeat.yml'-UseBasicParsing -OutFile $winlogbeatPath;
  Write-Host "$('[{0:HH:mm}]' -f Green (Get-Date)) Success!"
}
Catch {
  Write-Host "$('[{0:HH:mm}]' -f Red (Get-Date)) An error occured: $_"
}

# Start Winlogbeat
Set-Location -Path "$winlogbeatPath"
Write-Host "$('[{0:HH:mm}]' -f Yellow (Get-Date)) Starting winlogbeat service..."
Try {
  Start-Service -Name winlogbeat
  Write-Host "$('[{0:HH:mm}]' -f Green (Get-Date)) Success!"
}
Catch {
  Write-Host "$('[{0:HH:mm}]' -f Red (Get-Date)) An error occured: $_"
}