#!/bin/bash
#skripta za namestitev Zabbix Agenta na Ubuntu 20.04
#Verzija: 0.5
#Izdelano: 12/2020

#Shortcuts are curtesy of: https://stackoverflow.com/a/16844327
#Text formatting shortcuts
RCol='\e[0m'    # Text Reset

# Regular           Bold                Underline           High Intensity      BoldHigh Intens     Background          High Intensity Backgrounds
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';    IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';    On_IBla='\e[0;100m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';    IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';    On_IRed='\e[0;101m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';    IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';    On_IGre='\e[0;102m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';    IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';    On_IYel='\e[0;103m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';    IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';    On_IBlu='\e[0;104m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';    IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';    On_IPur='\e[0;105m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';    ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';    On_ICya='\e[0;106m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';    IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';    On_IWhi='\e[0;107m';
WhiteOnRedbg='\e[0;97;41m';


proxyAddress=""
#downloadFileUrl="http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1%2Bbionic_all.deb"
downloadFileUrl="https://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu$(lsb_release -rs)_all.deb"
echo "Vnesi IP naslov lokalnega Zabbix Proxy strežnika in pritistni [ENTER]:"
read proxyAddress
ping -c 1 -W 1 $proxyAddress > /dev/null
if [ $? -eq 0 ]
then
        echo $(tput setaf 2)Ping uspesen. Nadaljujem...$(tput sgr0)
else
        echo "$(tput setaf 1)Proxy ping ni uspel. Preveri vnešeni hostname, IP naslov ali domeno in poizkusi ponovno!"$(tput sgr0)
        exit 0
fi

#downloada .deb in shrani filename v $downloadFilename
echo $(tput setaf 2)Downloading sources...$(tput sgr0)
downloadFilename=$(wget -nv $downloadFileUrl 2>&1 | cut -d\" -f2)

echo $downloadFilename

#namestimo .deb file
echo $(tput setaf 2)Installing sources...$(tput sgr0)
dpkg -i $downloadFilename

#update apt cache
apt update

#install zabbix agent paket
echo $(tput setaf 2)Installing package zabbix-agent$(tput sgr0)
apt -y install zabbix-agent2

#nastavi zabbix agent da se zazene ob rebootu
echo $(tput setaf 2)Setting Zabbix agent run at startup...$(tput sgr0)
systemctl start zabbix-agent2.service
systemctl enable zabbix-agent2.service

#pridobi hostname serverja za vpis v config file
proxyHostname=$(hostname)

#ustavi agenta preden urejamo .conf file
echo $(tput setaf 2)Stopping Zabbix Agent to configure...$(tput sgr0)
service zabbix-agent2 stop

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

#zazene proxy nazaj
echo $(tput setaf 2)Starting Zabbix Agent service...$(tput sgr0)
service zabbix-agent2 start