docker build -f Dockerfile.base.1 -t ackdev/secure_java_developer_desktop-base-1:$dVersion . --build-arg \
	http_proxy="$proxy" --build-arg https_proxy="$proxy" 2>&1 | tee "$log_dir/docker_build.out"
	
grep -i "SUDO password" "$log_dir/docker_build.out" >"$HOME/logs/docker/SUDO-secure_java_developer_desktop-$current_timestamp"
