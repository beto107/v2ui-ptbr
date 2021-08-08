#!/bin/bash
apt update;
curl -L https://github.com/andley302/v2ui-ptbr/master/v2-ui-linux-amd64.tar.gz  -o v2-ui-linux.tar.gz;
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
curl -o /usr/bin/v2-ui -Ls https://github.com/andley302/v2ui-ptbr/master/v2-ui.sh;
chmod +x /usr/bin/v2-ui;