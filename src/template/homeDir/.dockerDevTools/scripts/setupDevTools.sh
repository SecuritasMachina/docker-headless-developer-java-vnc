#!/usr/bin/env bash
### every exit != 0 fails the script
#echo "Checking for application installation"
$HOME/.dockerDevTools/scripts/setupMySQLv8.x.sh
$HOME/.dockerDevTools/scripts/setupTomcatv8.x.sh
$HOME/.dockerDevTools/scripts/setupEclipse.sh
