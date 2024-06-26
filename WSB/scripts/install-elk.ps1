# Purpose: Installs Elasticsearch, Logstash, and Kibana (ELK) and the winlogbeat agent using Chocolatey
# Also configures their respective .yml and .conf files from GitHub

$packages = @("winlogbeat", "elasticsearch", "logstash", "kibana")
$repo = "https://raw.githubusercontent.com/d1ll3x/PurpleBox/main/config/elk"

Set-ExecutionPolicy Bypass -Scope Process -Force

# Installing packages from Chocolatey
foreach ($package in $packages) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing $package..."
  Try {
      choco install $package -y
  }
  Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $package failed to install! An error occured: $_"
  }
}

# Download config files from repo
foreach ($package in $packages) {
  $version = choco list $package | Where-Object { $_ -match $package } | ForEach-Object { ($_ -split ' ')[1] }
  $path = "C:\ProgramData\chocolatey\lib\$package\tools\$package-$version"

  if ($package -eq "logstash" ) {
    Try {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading winlogbeat.conf..."
      Invoke-WebRequest "$repo/winlogbeat.conf"-UseBasicParsing -OutFile "$path/config/winlogbeat.conf"
      
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading $package.yml..."
      Invoke-WebRequest "$repo/$package.yml"-UseBasicParsing -OutFile "$path/config/$package.yml"
    }
    Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to download config files for: $package An error occured: $_"
    }
  }

  elseif ($package -eq "winlogbeat" ) {
    $path = "C:\ProgramData\chocolatey\lib\$package\tools"
      Try {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading $package.yml..."
        Invoke-WebRequest "$repo/$package.yml"-UseBasicParsing -OutFile "$path/$package.yml"
      }
      Catch {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to download $package.yml. An error occured: $_"
      }
  }
  elseif ($package -ne "winlogbeat") {
    Try {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading $package.yml..."
      Invoke-WebRequest "$repo/$package.yml"-UseBasicParsing -OutFile "$path/config/$package.yml"
    }
    Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to download $package.yml. An error occured: $_"
    }
  }
}

# Starting the ELK stack
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Initialzing the ELK stack..."
foreach ($package in $packages) {
  if ($package -eq "logstash" ) {
    $version = choco list $package | Where-Object { $_ -match $package } | ForEach-Object { ($_ -split ' ')[1] }
    $path = "C:\ProgramData\chocolatey\lib\$package\tools\$package-$version"
    Try {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating $package service with NSSM..."
      nssm install $package "$path/bin/$package.bat" -f "$path/config/winlogbeat.conf"
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Starting $package..."
      nssm start "$package"
    }
    Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Failed to create the service: $package. An error occured: $_"
    }
  }
  elseif ($package -ne "logstash" ) {
    Try {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Starting $package..."
      get-service "$package*" | Start-Service
    }
    Catch {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Failed to start service: $package. An error occured: $_"
    }
  }
}
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) All done, ELK is up and running!"