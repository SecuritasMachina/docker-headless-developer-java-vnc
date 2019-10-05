#!/bin/bash
### every exit != 0 fails the script
## print out help
help (){
echo "
USAGE:
docker run -it -p 6901:6901 -p 5901:5901 consol/<image>:<tag> <option>

IMAGES:
consol/ubuntu-xfce-vnc
consol/centos-xfce-vnc
consol/ubuntu-icewm-vnc
consol/centos-icewm-vnc

TAGS:
latest  stable version of branch 'master'
dev     current development version of branch 'dev'

OPTIONS:
-w, --wait      (default) keeps the UI and the vncserver up until SIGINT or SIGTERM will received
-s, --skip      skip the vnc startup and just execute the assigned command.
                example: docker run consol/centos-xfce-vnc --skip bash
-d, --debug     enables more detailed startup output
                e.g. 'docker run consol/centos-xfce-vnc --debug bash'
-h, --help      print out this help

Fore more information see: https://github.com/ConSol/docker-headless-vnc-container
"
}
if [[ $1 =~ -h|--help ]]; then
    help
    exit 0
fi

PATH=/usr/sbin:$PATH

# Enable firewall to disable outbound connections to force container to use proxy

ufw default deny outgoing
ufw default deny incoming
ufw allow 5901
ufw allow 6901
ufw allow out 53
ufw allow out 8000
ufw allow out 3128
ufw enable

rsync -a $HOME/* /home/$CONTAINER_DIR_NAME/
rsync -a $HOME/.[^.]* /home/$CONTAINER_DIR_NAME/

rm -rf $HOME
ln -s /home/$CONTAINER_DIR_NAME $HOME
cd $HOME
whoami
updatedb

echo "Clearing firefox cache, cookies, files etc in :"
sudo -E /bin/bash -c 'for f in `find $HOME/.cache -type d -name "entries"`; do echo "$f"; done'
sudo -E /bin/bash -c 'for f in `find $HOME/.cache -type d -name "entries"`; do rm -f "$f/*"; done'
sudo -E /bin/bash -c 'for f in `find $HOME/.cache -type d -name "Blobs"`; do echo "$f"; done'
sudo -E /bin/bash -c 'for f in `find $HOME/.cache -type d -name "Blobs"`; do rm -f "$f/*"; done'

su ${CONTAINER_USER} -c "bash /dockerstartup/entrypoint2.sh"


