# Purpose: Installs Elasticsearch, Logstash, and Kibana (ELK) and the winlogbeat agent using Chocolatey
# Also configures their respective .yml and .conf files from GitHub

$packages = @("winlogbeat", "elasticsearch", "logstash", "kibana")

Set-ExecutionPolicy Bypass -Scope Process -Force;

# Installing packages from Chocolatey
foreach ($package in $packages) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing $package..."
  Try {
      choco install $package -y
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Success!"
  }
  Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $package failed to install! An error occured: $_"
  }
}

# Download config files from repo
foreach ($package in $packages) {
  $version = choco list $package | Where-Object { $_ -match $package } | ForEach-Object { ($_ -split ' ')[1] }
  $path = "C:\ProgramData\chocolatey\lib\$package\tools\$version"

  if ($package -eq "logstash" ) {
    Try {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading $package.yml..."
      Invoke-WebRequest "https://raw.githubusercontent.com/d1ll3x/PurpleBox/main/ELK/config/$package.yml"-UseBasicParsing -OutFile "$path/config";
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading winlogbeat.conf..."
      Invoke-WebRequest "https://raw.githubusercontent.com/d1ll3x/PurpleBox/main/ELK/config/winlogbeat.conf"-UseBasicParsing -OutFile "$path/config";
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Success!"
    }
    Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to download config files for: $package An error occured: $_"
    }
  }

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading $package.yml..."
  Try {
    Invoke-WebRequest "https://raw.githubusercontent.com/d1ll3x/PurpleBox/main/ELK/config/$package.yml"-UseBasicParsing -OutFile "$path/config";
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Success!"
  }
  Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to download $package.yml. An error occured: $_"
  }
}

# Starting the ELK stack
foreach ($package in $packages) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Initialzing the ELK stack..."
  if ($package -eq "logstash" ) {
    Try {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating Logstash service with NSSM..."
      nssm install $package "$path/bin" [-f "$path/config/winlogbeat.conf"] 
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Success!"
    }
    Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) An error occured: $_"
    }
  }
  Try {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Starting $package..."
    get-service "$package*" | Start-Service
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Success!"
  }
  Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Failed to start $package. An error occured: $_"
  }
}
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) All done, ELK is up and running!"