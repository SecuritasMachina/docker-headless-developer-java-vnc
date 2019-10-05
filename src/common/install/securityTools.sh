#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Security Related tools"
source $INST_SCRIPTS/commonFunctions.sh
retry wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd --quiet
retry wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd --quiet 
retry wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd --quiet

# permission juggling
chown -R clamav:clamav /var/lib/clamav
chmod ug+rwx /var/lib/clamav
chmod g+s /var/lib/clamav

mkdir /var/run/clamav
chown -R clamav:clamav /var/run/clamav
chmod ug+rwx /var/run/clamav
chmod g+s /var/run/clamav

mkdir -p /var/log/clamav
touch /var/log/clamav/clamav.log
touch /var/log/clamav/freshclam.log
chown -R clamav:clamav /var/log/clamav
chmod -R ug+rw /var/log/clamav
chmod -R g+s /var/log/clamav
