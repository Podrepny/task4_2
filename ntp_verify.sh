#! /bin/bash

LANG=C.UTF-8
NTP_SRV="ua.pool.ntp.org"
NTP_CFG="/etc/ntp.conf"
NTP_ORIG="/etc/ntp.conf.bak"

# Check ntp install
PKG_STATUS=`apt-cache policy ntp | grep "Installed" | awk '{print $2}'`
if [[ $PKG_STATUS == "" || $PKG_STATUS == "(none)" ]]; then
	echo "Service ntp not installed!"
	exit 1
fi
# Check service status
service ntp status 2>&1 > /dev/null
SERVICE_STATUS=$?


# Check ntp.conf
if [ -f "$NTP_CFG" ] || [ -f "$NTP_ORIG" ]; then
	NTP_CFG_DIFF=`diff -u "$NTP_CFG" "$NTP_ORIG"`
	NTP_CFG_STAT=$?
else
	echo "No such file $NTP_CFG or $NTP_ORIG"
fi

if [ $NTP_CFG_STAT -ne "0" ] ; then
	echo -e "\nNOTICE: /etc/ntp.conf was changed. Calculated diff:"
	echo "$NTP_CFG_DIFF"
	sudo cp "$NTP_ORIG" "$NTP_CFG"
fi

if [ $SERVICE_STATUS -ne "0" ]; then
	 sudo service ntp restart
fi

exit 0

