Docker container image for Headless Java Developer using VNC session

This repository contains a collection of Docker images with headless VNC environments.

[Hosting and usage tips](https://github.com/ackdev/docker-headless-developer-java-vnc/wiki) | [Releases](https://github.com/ackdev/docker-headless-developer-java-vnc/releases)

Each Docker image is installed with the following components:

* Desktop environment [**xfce** Coming soon **Gnome**]

* OpenJDK 8.0
* MySQL 8.0.15
* Tomcat 9.0.44
* NPM 3.5.x 
* ClamAV
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client (default http port `6901`)
* Browsers:
  * Mozilla Firefox
  * Chromium

## Why?
* [26% of firms suffered breaches in 2018 due to vulnerable open source components](https://www.scmagazineuk.com/26-firms-suffered-breaches-2018-due-vulnerable-open-source-components/article/1577856)
* [Open source software breaches surge in the past 12 months](https://www.zdnet.com/article/open-source-software-breaches-surge-in-the-past-12-months/)
* [Open source breaches up by 71 percent](https://betanews.com/2019/03/04/open-source-breaches-up/)
* [Secure open source components to bypass breaches](https://searchsoftwarequality.techtarget.com/tip/Secure-open-source-components-to-bypass-breaches)
* [More...](https://www.google.com/search?q=open+source+breaches)


## Security Precautions
   
### Image Build
* Major & Minor .x releases are built, scanned for viruses and pushed from Google Compute VM  which is only spun up for build and push, then shutdown for minimal exposure
* All packages are checked for updates
* Tomcat, MySQL and Eclipse signatures are checked against vendor public key and file hash

### Runtime 
* Restricted developer rights, sudo password in only available in build log 
* Active virus, malware & bytecode directory scanning using ClamAV: ~/Downloads, Maven's .m2 and Gradle's .gradle
* Daily ClamAV database updates
* Must use a proxy, here's a [whitelist](https://github.com/ackdev/docker-headless-developer-java-vnc/blob/master/src/sample/20-whitelist) which may be used as a starting point.

### Persistance
* User's home directory is persisted  

## Build
* Setup Docker: https://docs.docker.com/get-started/
* ./buildAll.sh


## Usage
Usage is **similar** for all provided images, e.g. for `ackdev/docker-headless-developer-java-vnc`:

```
proxy="http://$proxy_ip:$proxy_port"
docker run --cap-add=NET_ADMIN -it -e VNC_RESOLUTION=1800x900 -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/DockerVolume:/home/superstar/hostVolume ackdev/secure_java_developer_desktop:latest
```

- Print out help page:

      docker run ackdev/docker-headless-developer-java-vnc:latest --help

- Run command with mapping to local port `5901` (vnc protocol) and `6901` (vnc web access):

      docker run -d -p 5901:5901 -p 6901:6901 -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc:latest
  
- Change the default user and group within a container to your own with adding `--user $(id -u):$(id -g)`:

      docker run -d -p 5901:5901 -p 6901:6901 --user $(id -u):$(id -g) -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc:latest

- If you want to get into the container use interactive mode `-it` and `bash`
      
      docker run -it -p 5901:5901 -p 6901:6901 -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc:latest bash

- Build an image from scratch:
      git clone https://github.com/ackdev/docker-headless-developer-java-vnc
      cd docker-headless-developer-java-vnc  
      docker build .  

# Connect & Control
If the container is started like mentioned above, connect via one of these options:

* connect via __VNC viewer `localhost:5901`__, check run output for randomly generated password
* connect via __noVNC HTML5 full client__: [`http://localhost:6901/vnc.html`](http://localhost:6901/vnc.html), check run output for randomly generated password 
* connect via __noVNC HTML5 lite client__: [`http://localhost:6901/?password=??????`](http://localhost:6901/?password=?????) 


## Hints

### 1) Extend a Image with your own software
Since version `1.0.0` all images run as non-root user per default, so if you want to extend the image and install software, you have to switch back to the `root` user:

```bash
## Custom Dockerfile
FROM ackdev/docker-headless-developer-java-vnc
ENV REFRESHED_AT 2019-03-18

# Switch to root user to install additional software
USER 0

## Install a gedit
RUN yum install -y gedit \
    && yum clean all

## switch back to default user
USER 1500
```

### 2) Change User of running Container

Per default, since version `1.0.0` all container processes will be executed with user id `1500`. You may change the user id as follows: 

#### 2.1) Using root (user id `0`)
Add the `--user` flag to your docker run command:

    docker run -it --user 0 -p 6911:6901 -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc

#### 2.2) Using user and group id of host system
Add the `--user` flag to your docker run command:

    docker run -it -p 6911:6901 --user $(id -u):$(id -g) -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc

### 3) Override VNC environment variables
The following VNC environment variables may be overwritten at the `docker run` phase to customize your desktop environment inside the container:
* `VNC_COL_DEPTH`, default: `24`
* `VNC_RESOLUTION`, default: `1280x1024`

#### 3.1) Example: Override the VNC resolution
Simply overwrite the value of the environment variable `VNC_RESOLUTION`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_RESOLUTION=800x600 -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc
    
### 4) View only VNC
Since version `1.0.0` it's possible to prevent unwanted control via VNC. Therefore you may set the environment variable `VNC_VIEW_ONLY=true`. If set, the startup script will create a random password for the control connection and use the value of `VNC_PW` for view only connection over the VNC connection.

     docker run -it -p 5901:5901 -p 6901:6901 -e VNC_VIEW_ONLY=true -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc

### 5) Known Issues

#### 5.1) Chromium crashes with high VNC_RESOLUTION ([#53](https://github.com/ConSol/docker-headless-vnc-container/issues/53))
If you open some graphic/work intensive websites in the Docker container (especially with high resolutions e.g. `1920x1080`) Chromium may crash without any specific reason. The problem there is the too small `/dev/shm` size in the container. Currently there is no other way, as define this size on startup via `--shm-size` option, see [#53 - Solution](https://github.com/ConSol/docker-headless-vnc-container/issues/53#issuecomment-347265977):

    docker run --shm-size=256m -it -p 6901:6901 -e VNC_RESOLUTION=1920x1080 -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" -e http_proxy="$proxy" -e https_proxy="$proxy" -v ~/containerdatavolume:/home/superstar/hostVolume ackdev/docker-headless-developer-java-vnc chromium-browser http://map.norsecorp.com/
  

## Release History

The current change log is provided here: **[Releases](https://github.com/ackdev/docker-headless-developer-java-vnc/releases)**

## Contact
For questions, professional support or maybe some hints, feel free to contact me via **[charles@ackdev.com](mailto:charles@ackdev.com)** or open an [issue](https://github.com/ConSol/docker-headless-vnc-container/issues/new).  

For consulting and maintenance agreements, we accept the following forms of payment:  
* BTC: qr70z6l6fhryhv952gs0klsx5mh3trw9e5t9rgrala
* ETH: 0x067bAf8A0468b3Fa32088B8A536e58622BC3BB2C
* LTC: MN3vyozGhMeyjGTA9pZJ1NX8JHXwNrpWXf 


## Bux for Bugs

Found a vulnerability?  Let us know and we'll send a reward for your time

## License
Apache License 2.0

