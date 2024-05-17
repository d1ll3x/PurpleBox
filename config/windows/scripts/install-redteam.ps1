# Shutup Windows Defender
If ((Get-Service -Name WinDefend -ErrorAction SilentlyContinue).status -eq 'Running') {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Uninstalling Windows Defender..."
  Try {
    Uninstall-WindowsFeature Windows-Defender -ErrorAction Stop
    Uninstall-WindowsFeature Windows-Defender-Features -ErrorAction Stop
  } Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Windows Defender did not uninstall successfully..."
  }
} Else  {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Windows Defender has already been disabled or uninstalled."
}

# Install dependencies
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing dependencies for Invoke-AtomicRedTeam..."
Install-PackageProvider -Name NuGet -Force
Install-Module -Name powershell-yaml -Force

# Download and install Invoke-AtomicRedTeam
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Invoke-AtomicRedTeam and atomic tests..."
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics -InstallPath "c:\Tools\AtomicRedTeam"
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Updating Profile.ps1 to import the Invoke-AtomicRedTeam module..."
Add-Content -Path C:\Windows\System32\WindowsPowerShell\v1.0\Profile.ps1 'Import-Module "C:\Tools\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force