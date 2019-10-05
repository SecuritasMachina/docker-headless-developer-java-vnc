CURRENT_TIMESTAMP=$(date +%Y-%m-%d_%H.%M)
logDir="$HOME/logs/docker/secure_java_developer_desktop/$CURRENT_TIMESTAMP"
mkdir -p $logDir
echo "Log Dir: $logDir"
tmpfile=$(mktemp)
export TEMPDIR=$(mktemp -d)

host_ip_cmd=($(echo $(hostname -I) | tr ' ' '\n'))
proxy_ip="${host_ip_cmd[0]}"
proxy_port="3128"
# Replace Proxy with company proxy:
proxy="http://$proxy_ip:$proxy_port"
echo "Using proxy: $proxy"

docker build -t ackdev/secure_java_developer_desktop:$CURRENT_TIMESTAMP \
	--build-arg http_proxy="$proxy" --build-arg https_proxy="$proxy" \
	2>&1 . | tee "$logDir/docker.out"

volume_path=/home/shared/DockerVolumes/developer-desktop

echo "Checking for $volume_path"

if [ ! -d $volume_path ]; then
    echo "!! $volume_path not found !! - aborting run"
    exit 1
fi
	
dgoss run --entrypoint="/dockerstartup/entrypoint.sh" --cap-add=NET_ADMIN -it -v $volume_path:/home/hostVolume ackdev/secure_java_developer_desktop:$CURRENT_TIMESTAMP >$logDir/dgoss.out
cat $logDir/dgoss.out
grep -i "SUDO password" "$logDir/docker.out"
read -p "Press [Enter] key to start 'ackdev/secure_java_developer_desktop:$CURRENT_TIMESTAMP' container"
echo "docker run --cap-add=NET_ADMIN -it -e VNC_RESOLUTION=1800x900 -e http_proxy=\"$proxy\" -e https_proxy=\"$proxy\" -v ~/DockerVolumes/developer-desktop:/home/hostVolume secure_java_developer_desktop:$CURRENT_TIMESTAMP"
#echo "Clearing firefox cache, cookies, files etc in :"
sudo -E /bin/bash -c 'for f in `find $volume_path/.cache -type d -name "entries"`; do echo "$f"; done'
sudo -E /bin/bash -c 'for f in `find $volume_path/.cache -type d -name "entries"`; do rm -f "$f/*"; done'
sudo -E /bin/bash -c 'for f in `find $volume_path/.cache -type d -name "Blobs"`; do echo "$f"; done'
sudo -E /bin/bash -c 'for f in `find $volume_path/.cache -type d -name "Blobs"`; do rm -f "$f/*"; done'
 
docker run --cap-add=NET_ADMIN -it -e VNC_RESOLUTION=1800x900 \
	-e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" \
	-e https_proxy="$proxy" -v $volume_path:/home/hostVolume \
	ackdev/secure_java_developer_desktop:$CURRENT_TIMESTAMP
