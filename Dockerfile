# Headless Ubuntu VNC Container with xfce window manager, OpenJDK 17, Eclipse, Tomcat, MySQL, MySQL Workbench, Firefox
FROM ackdev/secure_java_developer_desktop-base-xfce:2026-06-23-r1

LABEL maintainer="Acknowledged Development Inc. help@ackdev.com"

LABEL io.k8s.description="Headless VNC Container with xfce window manager, OpenJDK 17, Eclipse, Tomcat, MySQL, MySQL Workbench, Firefox" \
      io.k8s.display-name="Headless Enterprise Developer VNC Container based on xfce" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, xfce" \
      io.openshift.non-scalable=true

ENV TERM=xterm \
	SHELL=/bin/bash
# Install Google Chrome from Google's signed APT repository (verified via the
# repo signing key) instead of an unverified one-off .deb download.
RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
      | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
      > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

### Install security tools
RUN $INST_SCRIPTS/securityTools.sh

### Configure security
RUN $INST_SCRIPTS/applyHomePermissions.sh

### Configure storage
RUN $INST_SCRIPTS/configureStorage.sh

### configure startup
ADD ./src/common/scripts $STARTUPDIR

RUN $INST_SCRIPTS/applyHomePermissions.sh
RUN $INST_SCRIPTS/configureSecurity.sh $STARTUPDIR
ADD src/template/etc /etc
RUN $INST_SCRIPTS/finalizeSecurity.sh

### Finalize installation & clean-up
RUN $INST_SCRIPTS/finalize.sh

ENTRYPOINT ["/dockerstartup/entrypoint.sh"]
CMD ["--wait"]
