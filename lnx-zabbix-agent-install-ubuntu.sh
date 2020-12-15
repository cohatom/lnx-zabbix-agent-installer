#!/bin/bash
#skripta za namestitev Zabbix Agenta na Ubuntu 20.04
#Verzija: 0.5
#Izdelano: 12/2020

proxyAddress=""
downloadFileUrl="https://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu$(lsb_release -rs)_all.deb"

read -p $(tput setaf 2)"Enter Zabbix $(tput bold)Proxy$(tput sgr0)$(tput setaf 2) address and press [ENTER]: "$(tput sgr0) proxyAddress

ping -c 1 -W 1 $proxyAddress > /dev/null
if [ $? -eq 0 ]
then
        echo $(tput setaf 2)"Ping successful. Moving on..."$(tput sgr0)
else
        echo $(tput setaf 1)"Ping failed. Check hostname, IP address or domain and try again!"$(tput sgr0)
        exit 0
fi

#downloada .deb in shrani filename v $downloadFilename
echo $(tput setaf 2)Downloading sources...$(tput sgr0)
downloadFilename=$(wget -nv $downloadFileUrl 2>&1 | cut -d\" -f2)

#echo $downloadFilename

#namestimo .deb file
echo $(tput setaf 2)Installing sources...$(tput sgr0)
dpkg -i $downloadFilename > /dev/null

#update apt cache
echo $(tput setaf 2)Running apt-get update...$(tput sgr0)
apt-get update > /dev/null

#install zabbix agent paket
echo $(tput setaf 2)Installing package zabbix-agent$(tput sgr0)
apt-get -y install zabbix-agent2 > /dev/null

#nastavi zabbix agent da se zazene ob rebootu
echo $(tput setaf 2)Setting Zabbix agent run at startup...$(tput sgr0)
systemctl start zabbix-agent2.service > /dev/null
systemctl enable zabbix-agent2.service > /dev/null

#pridobi hostname serverja za vpis v config file
proxyHostname=$(hostname)

#ustavi agenta preden urejamo .conf file
echo $(tput setaf 2)Stopping Zabbix Agent to configure...$(tput sgr0)
service zabbix-agent2 stop > /dev/null

#premaknemo originalen zabbix_proxy.conf file
echo "Moving original zabbix_agent.conf to /etc/zabbix/zabbix_agent.conf.example just in case..."
mv /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.example

#kreira nov zabbix_proxy.conf file z nasimi nastavitvami
echo $(tput setaf 2)Creating new Zabbix Agent config file...$(tput sgr0)
cat > /etc/zabbix/zabbix_agent2.conf << EOF
Server=$proxyAddress
ServerActive=$proxyAddress
Hostname=$proxyHostname
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=50
EnableRemoteCommands=1
LogRemoteCommands=1
PidFile=/var/run/zabbix/zabbix_agent2.pid
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

#zazene agenta
echo $(tput setaf 2)Starting Zabbix Agent service...$(tput sgr0)
service zabbix-agent2 start > /dev/null

systemctl is-active --quiet zabbix-agent2
if [ $? = 0 ]
then
        echo $(tput setaf 2)Zabbix Agent service is RUNNING$(tput sgr0)
else
        echo "$(tput setaf 1)Oh no... Zabbix Agent service is NOT running. Exiting script!"$(tput sgr0)
        exit 0
fi