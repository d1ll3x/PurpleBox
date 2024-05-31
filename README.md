![Purplebox](purplebox.png)

Purple Box is a local security testing environment aimed at testing detection rules and attack tactics and techniques. The goal behind the project is to allow blue and red teamers a very agile method to get a testing environment up and running on their local Windows based device without having to rely on remote infrastructure.

**Purple Box is not a replacement for your security testing infrastructure, but rather a starting point for security testing for personal or professional use**

## Prerequisites
In order to use purple box on your Windows workstation your system must be configured with the following Windows features:
- [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview#installation)

## Getting Started
This project uses Windows Sandbox as the testing environment which is equiped with the renowned testing framework from Atomic Red Team, known as Invoke-AtomicRedTeam.

After satisyfing the prerequisites the only thing you need to do is to download your .wsb config file that corresponds to your SIEM platform of choice.

Currently the following .wsb files are available for you to use:
- [ELK.wsb](https://github.com/d1ll3x/PurpleBox/blob/main/WSB/ELK.wsb)

### ELK
If you choose the ELK.wsb file the ELK stack will run locally in the windows sandbox without having to rely on any cloud solutions.
To work with the ELK stack:
- Open the browser and navigate to localhost:5601 (default kibana port)
- Whenever you execute an atomic from the command line you can review this by looking at the data in Kibana

All YAML config files are set to default for each ELK component and for the winlogbeat agent. There is however, one exception made for elasticsearch.
xpack.security.enabled is set to false to avoid hassle with tokens for the other ELK components to connect to the elasticsearch environment. **This is generally not best practice, but this sandbox should be considered as a development/test environment**