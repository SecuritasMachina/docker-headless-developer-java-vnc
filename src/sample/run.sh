#!/usr/bin/env bash
host_ip_cmd=($(echo $(hostname -I) | tr ' ' '\n'))
proxy_ip="${host_ip_cmd[0]}"
proxy_port="3128"
# Replace Proxy with company proxy:
proxy="http://$proxy_ip:$proxy_port"
echo "Using proxy: $proxy"
volume_path=/home/shared/DockerVolumes/developer-desktop
echo "Checking for $volume_path"

if [ ! -d $volume_path ]; then
    echo "!! $volume_path not found !! - aborting run"
    exit 1
fi
echo "Clearing firefox cache, cookies, files etc in :"
for f in `find $volume_path/.cache -type d -name "entries"`; do echo "$f"; done
for f in `find $volume_path/.cache -type d -name "entries"`; do rm -f "$f/*"; done

docker run --cap-add=NET_ADMIN -it -e VNC_RESOLUTION=1800x900 \
	-e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" \
	-e https_proxy="$proxy" -v $volume_path:/home/hostVolume \
	ackdev/secure_java_developer_desktop:2019-05-01_10.26.50
