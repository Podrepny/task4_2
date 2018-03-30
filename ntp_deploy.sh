#!/bin/bash

LANG=C.UTF-8

NTP_SRV="ua.pool.ntp.org"
NTP_CFG="/etc/ntp.conf"
NTP_ORIG="/etc/ntp.conf.bak"
CRON_FILE="/etc/cron.d/ntp_verify"

# Start installing NTP
PKG_STATUS=`apt-cache policy ntp | grep "Installed" | awk '{print $2}'`
if [[ $PKG_STATUS == "" || $PKG_STATUS == "(none)" ]]; then 
	sudo apt-get -y install ntp
	if [ $? -ne "0" ]; then
		echo "Installation NTP package failed"
		exit 1
	else
		# Remove default pools
                sudo sed -i 's/^pool .*$//g' $NTP_CFG
                sudo sh -c "echo 'pool $NTP_SRV' >> $NTP_CFG"
		sudo cp "$NTP_CFG" "$NTP_ORIG"
                sudo service ntp restart
	fi
else
	POOL_COUNT=`cat $NTP_CFG | grep "^pool $NTP_SRV$" | wc -l`
	if [[ "$POOL_COUNT" -eq "0" || "$POOL_COUNT" -gt "2" ]]; then
		# Remove default pools
		sudo sed -i 's/^pool .*$//g' $NTP_CFG
		sudo sh -c "echo 'pool $NTP_SRV' >> $NTP_CFG"
		sudo cp "$NTP_CFG" "$NTP_ORIG"
		sudo service ntp restart
	fi
fi

# Add to cron ntp_verify.sh
SCRIPT_NAME=$0
PATH_BEGIN="${SCRIPT_NAME:0:1}"
if [ "$PATH_BEGIN" == "/" ]; then
	PATH_WRK=`dirname $SCRIPT_NAME`
else
	PATH_A="`pwd`"
	PATH_B=`dirname "$SCRIPT_NAME" | sed 's/^\.\///g' | sed 's/\.$//g'`
	PATH_WRK=`echo "$PATH_A/$PATH_B" | sed 's/\/$//g'`
fi
CRON_STRING='*/1 * * * * root '$PATH_WRK'/ntp_verify.sh'
sudo sh -c "echo '$CRON_STRING' > $CRON_FILE"

exit 0
