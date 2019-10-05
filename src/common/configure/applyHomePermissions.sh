#!/usr/bin/env bash
echo "Apply Home directory permissions to $CONTAINER_USER Group ID: $EUID"
### every exit != 0 fails the script
set -e
if [[ -n $DEBUG ]]; then
    verbose="-v"
fi
# Grant User Permissions
find "$HOME"/ -name '*' -exec chmod $verbose a-rwx {} +
find "$HOME"/ -name '*.sh' -exec chmod $verbose ug+x {} +
find "$HOME"/ -name '*.desktop' -exec chmod $verbose ug+rwx {} +
find "$HOME"/ -type d -exec chmod +t {} +
chown -R $CONTAINER_USER:$CONTAINER_USER "$HOME" && chmod -R $verbose ug+rw "$HOME" && find "$HOME" -type d -exec chmod $verbose ug+x {} +
