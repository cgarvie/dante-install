#!/bin/bash 

# How to Install
# --------------
# ACCOUNTID=123 && bash <(curl -s https://raw.githubusercontent.com/cgarvie/dante-install/master/install.sh)         

AUTHUSER=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo ''`
AUTHPASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo ''`
AUTHPORT=`shuf -i 9000-9999 -n 1`

wget --no-check-certificate https://raw.github.com/Lozy/danted/master/install.sh -O install.sh 
bash install.sh -p --port=$AUTHPORT --user=$AUTHUSER --passwd=$AUTHPASS

service sockd stop
if [ -f "/etc/danted/sockd.conf" ]; then sed -i -e 's/^method: pam none$/method: username/g' -e 's/ method: pam$/ method: username/g' /etc/danted/sockd.conf; fi

useradd -s /sbin/nologin $AUTHUSER
echo "$AUTHUSER:$AUTHPASS"|chpasswd

service sockd start

# For your records. Dante does not read this as a config file.
echo "user=$AUTHUSER" > ~/.weeabo
echo "pass=$AUTHPASS" >> ~/.weeabo
echo "port=$AUTHPORT" >> ~/.weeabo

MACHINEID=`echo $AUTHUSER | /usr/bin/md5sum | cut -f1 -d" "`
curl https://weeabo.com/api/hello/new/$ACCOUNTID/$MACHINEID/$AUTHUSER/$AUTHPASS/$AUTHPORT/
crontab -l > mycron
#echo new cron into cron file
echo "*/5 * * * * curl https://weeabo.com/api/hello/up/$MACHINEID/" >> mycron
#install new cron file
crontab mycron
rm mycron

echo "All done. Check your dashboard on our website to see if install was completed successfully."


