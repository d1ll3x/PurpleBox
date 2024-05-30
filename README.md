![Purplebox](purplebox.png)

Purple Box is a fully local security testing environment aimed at testing detection rules and attack tactics and techniques. The goal behind the project is to allow blue and red teamers a very agile method to get a testing environment up and running on their local Windows based device without having to rely on remote infrastructure.

**Purple Box is not a replacement for your security testing infrastructure, but rather a starting point for security testing for personal or professional use**

## Prerequisites
In order to use purple box on your Windows workstation your system must be configured with the following Windows features:
- [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview#installation)
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)

### WSL2
Windows Subsystem for Linux is required to be able to receive and analyse logs and test detection rules in the ELK stack. Your WSL2 distro of choice must at least have the following components installed:
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/linux/)

### Windows Firewall
To be able to retrieve the logs from the Windows Sandbox environment you are required to create an inbound firewall rule to allow traffic from the Windows Sandbox. By doing so we can forward these logs through our host to our ELK stack by using logstash.

## Windows Sandbox (WSB)
This project uses Windows Sandbox as the testing environment which is equiped with Elastic's winlogbeat agent and the renowned testing framework from Atomic Red Team, known as Invoke-AtomicRedTeam.

The winlogbeat agent is configured to forward events to Logstash. Adjust the winlogbeat.yml to your logging requirements to ensure that your ELK environment is receiving ans parsing the logs in the correct format.

## ELK
The ELK stack is running on docker and is deployed with the supplied docker compose file. The stack is provisioned with static IPs which is not ideal, but unfortunately there is currently no other solution to reliably receive logs from the Windows Sandbox environment. 

Logstash is configured to accept connections from the winlogbeat agent.