#current_timestamp=$(date +%Y-%m-%d_%H.%M)
#log_dir="$HOME/logs/docker/$current_timestamp"
#mkdir -p $log_dir
#echo "Build logs at $log_dir" 

sudo apt-get update -y
sudo apt-get upgrade -y 2>&1 | tee "$log_dir/apt-upgrade.out"
echo "FreshClam"
sudo freshclam 2>&1 | tee "$log_dir/freshclam.out"
git fetch 2>&1 | tee "$log_dir/git_fetch.out"
git diff master...origin/master 2>&1 | tee "$log_dir/git_diff.out"
git pull 2>&1 | tee "$log_dir/git_pull.out"
docker build -t ackdev/secure_java_developer_desktop:$current_timestamp . 2>&1 | tee "$log_dir/docker_build.out"
echo "Clamscan Container"

docker run --entrypoint "/usr/bin/clamscan" --user 0 -it -v ~/DockerVolumes/developer-desktop:/home/hostVolume ackdev/secure_java_developer_desktop:$current_timestamp -ir --max-scansize=1000M --max-filesize=1000M --exclude-dir="^/sys" --exclude-dir="^/dev" /home /usr /root /run 2>&1 | tee "$log_dir/clamAVPost.out" & 
docker run --entrypoint "/usr/bin/clamscan" --user 0 -it -v ~/DockerVolumes/developer-desktop:/home/hostVolume ackdev/secure_java_developer_desktop:$current_timestamp -ir --max-scansize=1000M --max-filesize=1000M --exclude-dir="^/sys" --exclude-dir="^/dev" /var /bin /boot /etc /sbin 2>&1 | tee "$log_dir/clamAVPost.out" & 
docker run --entrypoint "/usr/bin/clamscan" --user 0 -it -v ~/DockerVolumes/developer-desktop:/home/hostVolume ackdev/secure_java_developer_desktop:$current_timestamp -ir --max-scansize=1000M --max-filesize=1000M --exclude-dir="^/sys" --exclude-dir="^/dev" /initrd.img /lib /lib64 /srv 2>&1 | tee "$log_dir/clamAVPost.out" & 
wait	

clam_result=`egrep -c 'Infected files: [0-9]*[1-9]' $log_dir/clamAVPost.out`
if [ $clam_result -gt 0 ]; then
	echo "!!! Container Virus found !!!"
	more $log_dir/clamAVPost.out
else
	dgoss run --cap-add=NET_ADMIN -it -v ~/DockerVolumes/developer-desktop:/home/hostVolume ackdev/secure_java_developer_desktop:$current_timestamp >$log_dir/dgoss.out
	cat $log_dir/dgoss.out
	echo "If no virus and unit tests pass push via:"
	echo "docker push ackdev/secure_java_developer_desktop-base-1:$dVersion"
	echo "docker push ackdev/secure_java_developer_desktop-base-devtools:$dVersion"
	echo "docker push ackdev/secure_java_developer_desktop-base-xfce:$dVersion"
	echo "docker push ackdev/secure_java_developer_desktop:$current_timestamp"
fi
