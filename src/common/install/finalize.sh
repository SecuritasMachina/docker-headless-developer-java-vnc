#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
apt autoremove -y && apt clean -y && apt purge -y
rm -f .wget-hsts
rm -rf install
rm -f nul