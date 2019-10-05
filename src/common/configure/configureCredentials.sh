#!/usr/bin/env bash
echo "Configure Credentials"
### every exit != 0 fails the script
set -e
###Set ClamAV User
groupadd clamav && useradd -g clamav clamav

### Set container user
if [ $USER_PASSWORD == "RANDOM_USER_PASSWORD" ]
then
      export USER_PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9#%^" | fold -w 32 | head -n 1)
      echo "Generated USER_PASSWORD: $USER_PASSWORD"
fi
groupadd -g 1500 ${CONTAINER_USER} && \
    useradd -r -u 1500 -g ${CONTAINER_USER} -G sudo ${CONTAINER_USER} \
    -p "$(openssl passwd -1 $USER_PASSWORD)"
echo "Created ${CONTAINER_USER} SUDO password: $USER_PASSWORD"

#Add CONTAINER_USER to clamav group 
usermod -a -G clamav ${CONTAINER_USER}
usermod -a -G adm ${CONTAINER_USER}

