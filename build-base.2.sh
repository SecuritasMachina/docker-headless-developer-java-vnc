docker build -f Dockerfile.base.2.devTools -t ackdev/secure_java_developer_desktop-base-devtools:$dVersion . \
	--build-arg http_proxy="$proxy" --build-arg https_proxy="$proxy" 2>&1 | tee "$log_dir/docker_build.out"
