export dVersion=2020-06-16-r1

export current_timestamp=$(date +%Y-%m-%d_%H.%M.%S)
export log_dir="$HOME/logs/docker/base-xfce/$current_timestamp"

mkdir -p $log_dir

echo "Log Dir: $log_dir"

export host_ip_cmd=($(echo $(hostname -I) | tr ' ' '\n'))
export proxy_ip="${host_ip_cmd[0]}"
export proxy_port="3128"
# Replace Proxy with company proxy:
#export proxy="http://$proxy_ip:$proxy_port"
echo "Using proxy: $proxy"
echo "Log Dir: $log_dir"



./build-base.1.sh
./build-base.2.sh
./build-base.3.sh
./build.sh