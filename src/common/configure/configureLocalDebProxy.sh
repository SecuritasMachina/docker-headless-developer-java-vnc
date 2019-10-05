###Check for host proxy
#route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
#echo "HEAD /" | nc 'cat /tmp/host_ip.txt' 3128 | grep squid-deb-proxy \
#  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):3128\";" > /etc/apt/apt.conf.d/30proxy) \
#  && (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
#  || echo "No squid-deb-proxy detected on docker host"
echo "Configure Proxy"
echo "HEAD /" | nc 192.168.1.246 3128 | grep squid-deb-proxy \
  && (echo "Acquire::http::Proxy \"http://192.168.1.246:3128\";" > /etc/apt/apt.conf.d/30proxy) \
  && (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected on docker host"
