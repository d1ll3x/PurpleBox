# Purpose: Installs the Winlogbeat agent to enable log forwarding
# Also configures winlogbeat.yml to connect to the ELK stack

# Be aware to use the desired winlogbeat version
$winlogbeatPath = "C:\ProgramData\Elastic\Winlogbeat"
$winlogbeatAgentVersion = "8.13.4"
$package = "winlogbeat-$winlogbeatAgentVersion-windows-x86_64"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating Winlogbeat directory..."
If(!(test-path $winlogbeatPath)) {
  New-Item -ItemType Directory -Force -Path $winlogbeatPath
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Winlogbeat directory already exists"
}

# Download the Winlogbeat package from elastic
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading winlogbeat zip..."
Try { 
  $zip = "$package.zip"
  $url = "https://artifacts.elastic.co/downloads/beats/winlogbeat/$zip"
  $tempPath = "C:\ProgramData\Elastic\"
  Invoke-WebRequest $url -OutFile $tempPath\$zip
} Catch { 
  Write-Host "HTTPS connection failed. Please check your network connection or the URL."
}

# Install Winlogbeat
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Winlogbeat agent..."
Try {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Extracting zip..."
    Expand-Archive -Path $tempPath/$zip -DestinationPath $tempPath

    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Moving extracted files to Winlogbeat directory..."
    Move-Item -Path "$tempPath\$package\*" -Destination $winlogbeatPath -Force

    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Cleaning up temporary directories..."
    Remove-Item -Path $tempPath/$zip -Recurse -Force
    Remove-Item -Path $tempPath/$package -Recurse -Force

    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Executing install-service-winlogbeat.ps1..."
    Set-Location -Path "$winlogbeatPath"
    .\install-service-winlogbeat.ps1

} Catch {
  Write-Host "Failed to install the Winlogbeat agent"
}


Start-Process msiexec.exe -ArgumentList "/i `"$winlogbeatDownload`" INSTALLDIR=`"$winlogbeatPath`" /quiet /norestart" -Wait

# Copy winlogbeat.yml file from the host machine
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Copying winlogbeat.yml config..."
$winlogbeatConfigPath = "\\host.lan\\Data\\winlogbeat.yml"
Copy-Item -Path $winlogbeatConfigPath -Destination $winlogbeatPath

# Start Winlogbeat
Set-Location -Path "$winlogbeatPath"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating and starting winlogbeat service..."
New-Service -Name winlogbeat -DisplayName winlogbeat -BinaryPathName "`"$winlogbeatPath\winlogbeat.exe`" -c `"$winlogbeatPath\winlogbeat.yml`" -path.home `"$winlogbeatPath`" -path.data `"$winlogbeatPath`""
Get-Service -Name winlogbeat | Start-Service