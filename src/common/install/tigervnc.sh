#!/usr/bin/env bash
set -e

echo "Install TigerVNC server"
source $INST_SCRIPTS/commonFunctions.sh

# Bintray was shut down in May 2021, so the old dl.bintray.com URL is dead.
# Fetch the self-contained generic Linux x86_64 build from the TigerVNC project
# on SourceForge over HTTPS instead.
TIGERVNC_VERSION=1.16.1
retry wget -qO- "https://downloads.sourceforge.net/project/tigervnc/stable/${TIGERVNC_VERSION}/tigervnc-${TIGERVNC_VERSION}.x86_64.tar.gz" \
    | tar xz --strip 1 --no-same-owner --no-same-permissions -C /
