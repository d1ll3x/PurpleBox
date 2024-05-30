# Purpose: Installs the invoke-atomicredteam powershell module to execute atomic tests

Set-ExecutionPolicy Bypass -Scope Process -Force;

# Installing NuGet dependency
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing NuGet..."
Try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}
Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) An error occured: $_"
}

# Installing Invoke-AtomicRedTeam from Red Canary
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Atomic Red Team..."
Try {
    Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1'-UseBasicParsing);
    Install-AtomicRedTeam -getAtomics -Force;
    New-Item $PROFILE -Force;
    Set-Variable -Name "ARTPath" -Value "C:\AtomicRedTeam"
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Successfully installed Invoke-AtomicRedTeam!"
}
Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) An error occured: $_"
}

Write-Output @"
Import-Module "$ARTPath/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1" -Force;
`$PSDefaultParameterValues`["Invoke-AtomicTest:PathToAtomicsFolder"] = "$ARTPath/atomics";
`$PSDefaultParameterValues`["Invoke-AtomicTest:ExecutionLogPath"]="1.csv";
"@ > $PROFILE

. $PROFILE

Set-Location C:\AtomicRedTeam