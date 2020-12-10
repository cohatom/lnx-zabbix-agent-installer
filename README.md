# lnx-zabbix-agent-installer
Automatic Linux Zabbix Agent installer for *Ubuntu 20.04*

# How to install
You need to use your username and password as repository is private for the time being. 

1. git clone https://username:"password"@github.com/cohatom/lnx-zabbix-agent-installer.git
2. cd lnx-zabbix-agent-installer
3. chmod +x lnx-zabbix-agent-installer.sh
4. ./lnx-zabbix-agent-installer.sh
5. At the prompt enter the IP address of local Zabbix proxy server.

**IMPORTANT:** If you enter invalid or unreachable IP address at the prompt script will fail!

## To-DO
* Pick agent version you want to install
* At the end check if service is running