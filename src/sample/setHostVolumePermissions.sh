export HOST_DIR=$HOME/DockerVolumes/developer-desktop
mkdir -p $HOST_DIR
sudo -Es
chown -R :1500 $HOST_DIR
chmod -R 775 $HOST_DIR
find $HOST_DIR -type d | xargs chmod g+s