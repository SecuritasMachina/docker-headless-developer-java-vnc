#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
source $INST_SCRIPTS/commonFunctions.sh
echo "Using Proxy: http_proxy=$http_proxy"
retry apt-get update && apt-get install -y --no-install-recommends language-pack-en-base openssl apt-utils net-tools software-properties-common locales
retry apt-get upgrade -y

locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
