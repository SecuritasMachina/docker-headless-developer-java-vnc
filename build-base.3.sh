
docker build -f Dockerfile.base.3.xfce -t ackdev/secure_java_developer_desktop-base-xfce:$dVersion . \
	--build-arg http_proxy="$proxy" --build-arg https_proxy="$proxy" 2>&1 | tee "$log_dir/docker_build.out"
