#!/bin/bash
##
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
##
apt update;
echo -e "${green}INSTALADOR V2-UI ${plain}";
echo -e "${plain}Aguarde...${plain}";
curl -L https://github.com/sprov065/v2-ui/releases/download/5.5.2/v2-ui-linux-amd64.tar.gz  -o v2-ui-linux.tar.gz;
cd /root/;
mv v2-ui-linux.tar.gz /usr/local/;
cd /usr/local/;
tar zxvf v2-ui-linux.tar.gz;
rm v2-ui-linux.tar.gz -f;
cd v2-ui;
chmod +x v2-ui bin/xray-v2-ui;
cp -f v2-ui.service /etc/systemd/system/;
systemctl daemon-reload;
systemctl enable v2-ui;
systemctl restart v2-ui;
curl -o /usr/bin/v2-ui -Ls https://raw.githubusercontent.com/Andley302/v2ui-ptbr/main/v2-ui.sh;
chmod +x /usr/bin/v2-ui;
clear;
echo -e "${green}INSTALADOR V2-UI FINALIZADO!${plain}"
echo -e "${plain}Use e comando v2-ui para abrir o menu${plain}"
