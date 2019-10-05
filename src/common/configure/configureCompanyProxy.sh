#TODO
#Set client to use company proxy
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.socks port ${LOCAL_PORT}
gsettings set org.gnome.system.proxy.socks host 'localhost'
gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '${LOCAL_RANGE}', '::1']"

git config --global http.proxy socks5h://127.0.0.1:1080
export https_proxy=https://localhost:1080
export http_proxy=http://localhost:1080
