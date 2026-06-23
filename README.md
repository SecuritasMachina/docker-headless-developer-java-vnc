# docker-headless-developer-java-vnc

A **hardened, headless Java developer desktop** that runs inside a Docker container and is accessed
remotely over VNC (Virtual Network Computing) or a browser via noVNC. It packages a full Linux desktop and
a Java toolchain so a developer can work in a disposable, locked-down, virus-scanned environment instead
of installing tools (and their supply-chain risk) directly on the host.

The image is built in layered stages on top of **Ubuntu 18.04** with an **xfce** desktop.

## What's inside

| Component | Notes |
|-----------|-------|
| Desktop | **xfce** window manager |
| Java | **OpenJDK 8** |
| App server | **Apache Tomcat 9.0.x** |
| Database | **MySQL 8.0.15** + **MySQL Workbench** |
| IDE | **Eclipse** (JEE 2019-03) |
| Build | **Gradle 5.0**, **npm** |
| Antivirus | **ClamAV** (on-access / scheduled directory scanning) |
| Remote access | **TigerVNC** server (VNC port `5901`) + **[noVNC](https://github.com/novnc/noVNC)** HTML5 client (HTTP port `6901`) |
| Browsers | **Mozilla Firefox**, **Chromium**, **Google Chrome** |

## Why a hardened developer container?

Modern builds pull in large dependency trees, and vulnerable or malicious open-source components are a
recurring source of breaches. Running development inside a constrained, scanned, network-restricted
container limits the blast radius: tools and downloaded artifacts are isolated from the host, traffic is
forced through a proxy/whitelist, and ClamAV scans the directories where dependencies and downloads land.

## Security model

### Build time
- Images are built, **virus-scanned**, and pushed from an ephemeral build VM that is spun up only for the
  build and shut down afterward to minimize exposure.
- All OS packages are updated during the build.
- Tomcat, MySQL, and Eclipse downloads are verified against vendor signatures / file hashes.
- A [goss](https://github.com/goss-org/goss) test suite (`goss.yaml`, run via `dgoss`) validates the
  finished image.

### Runtime
- **Non-root by default** — container processes run as an unprivileged user (uid `1500`); the sudo
  password is generated at build time and only appears in the build log.
- **Outbound proxy enforced** — traffic is expected to route through an HTTP/HTTPS proxy; see
  `src/sample/20-whitelist` for a starting allow-list. A firewall (ufw) is configured inside the image
  (hence `--cap-add=NET_ADMIN`).
- **Active malware scanning** — ClamAV scans dependency/download directories (e.g. `~/Downloads`, Maven
  `.m2`, Gradle `.gradle`) with daily signature database updates.

### Persistence
- The user's home directory is persisted via a mounted host volume (`/home/<user>/hostVolume`).

## Image layers

The build is split into layered Dockerfiles so the expensive base rarely rebuilds:

| Stage | Dockerfile | Contents |
|-------|-----------|----------|
| 1 — base | `Dockerfile.base.1` | Ubuntu 18.04 + core OS hardening |
| 2 — dev tools | `Dockerfile.base.2.devTools` | OpenJDK 8, Tomcat, MySQL, Eclipse, Gradle, npm |
| 3 — desktop | `Dockerfile.base.3.xfce` | xfce desktop, TigerVNC, noVNC |
| 4 — final | `Dockerfile` | Chrome, security tools, storage/startup configuration, entrypoint |

## Build

```bash
# Requires Docker: https://docs.docker.com/get-started/
git clone https://github.com/SecuritasMachina/docker-headless-developer-java-vnc
cd docker-headless-developer-java-vnc
./buildAll.sh        # builds stages 1 → 2 → 3 → final, then runs goss tests
```

`buildAll.sh` runs `build-base.1.sh`, `build-base.2.sh`, `build-base.3.sh`, and `build.sh` in order. See
`how-to-release.md` for the full build-scan-push release process.

## Usage

```bash
mkdir -p ~/ContainerDataVolume
proxy="http://$proxy_ip:$proxy_port"

docker run -d \
  --cap-add=NET_ADMIN \
  -p 5901:5901 -p 6901:6901 \
  -e VNC_RESOLUTION=1800x900 \
  -e HTTP_PROXY="$proxy" -e HTTPS_PROXY="$proxy" \
  -e http_proxy="$proxy" -e https_proxy="$proxy" \
  -v ~/ContainerDataVolume:/home/superstar/hostVolume \
  <image>
```

- **Help page:** `docker run <image> --help`
- **Interactive shell:** add `-it ... bash`
- **Run as your host user:** add `--user $(id -u):$(id -g)`

### Connect

- **VNC viewer:** `localhost:5901` — the password is in the run output (randomly generated).
- **noVNC full client:** <http://localhost:6901/vnc.html> — password in the run output.
- **noVNC lite client:** `http://localhost:6901/?password=<password>`

## Tips

### Extend the image with your own software
All processes run as a non-root user, so switch to root to install, then switch back:

```dockerfile
FROM <image>
USER 0
RUN apt-get update && apt-get install -y gedit && apt-get clean
USER 1500
```

### Change the container user
- As root: add `--user 0`
- As your host user/group: add `--user $(id -u):$(id -g)`

### Override the VNC environment
- `VNC_RESOLUTION` (default `1280x1024`), e.g. `-e VNC_RESOLUTION=800x600`
- `VNC_COL_DEPTH` (default `24`)
- `VNC_VIEW_ONLY=true` — disables remote control; a random control password is generated and `VNC_PW` is
  used for the view-only connection.

### Known issue — Chromium crashes at high resolutions
`/dev/shm` defaults too small in containers. Increase it on startup:

```bash
docker run --shm-size=256m -it -p 6901:6901 -e VNC_RESOLUTION=1920x1080 ... <image>
```

(See ConSol [docker-headless-vnc-container #53](https://github.com/ConSol/docker-headless-vnc-container/issues/53).)

## Heritage

This project descends from `ackdev/secure_java_developer_desktop`, which in turn builds on the
[ConSol docker-headless-vnc-container](https://github.com/ConSol/docker-headless-vnc-container) project.
Some older image names and links in scripts still reference the previous `ackdev/...` repository.

## License

[Apache License 2.0](LICENSE)
