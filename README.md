# Purple Box
This is a fully local security testing environment aimed at testing detection rules and attack tactics and techniques. The goal behind the project is to allow blue and red teamers a very agile method to get a testing environment up and running on their local device instead of having to rely on remote infrastructure.

## Windows Sandbox (WSB)
This project uses Windows Sandbox as the testing environment which is equiped with Elastic's winlogbeat agent and the renowned testing framework from Atomic Red Team, known as Invoke-AtomicRedTeam.

The winlogbeat agent is configured to forward events to Logstash. Adjust the winlogbeat.yml to your logging requirements to ensure that your ELK environment is receiving ans parsing the logs in the correct format.

## ELK
The ELK stack is running on docker and is deployed with the supplied docker compose file. The stack is provisioned with static IPs which is not ideal, but unfortunately there is currently no other solution to reliably receive logs from the Windows Sandbox environment. 

Logstash is configured to accept connections from the winlogbeat agent.