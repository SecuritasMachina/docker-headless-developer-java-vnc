# Composable developer-desktop stacks

This repo can assemble a headless VNC developer desktop from **components** —
one directory per technology — instead of a single hard-coded Dockerfile. An
admin (or you) picks the technologies, lists them in a **stack** file, and the
[`build-stack.sh`](build-stack.sh) builder resolves dependencies, generates a
Dockerfile, and builds the image.

```
components/<category>/<name>/   # one reusable technology each
stacks/<name>.stack             # a named recipe = a list of components
build-stack.sh                  # the assembler
stackbuild/                     # shared build helpers + runtime entrypoint
build/<stack>/Dockerfile        # generated output (git-ignored)
```

## Quick start

```bash
./build-stack.sh --list                  # see all stacks and components
./build-stack.sh --print java-enterprise  # preview the generated Dockerfile
./build-stack.sh --no-build polyglot      # generate the Dockerfile, don't build
./build-stack.sh java-web                 # generate + docker build
./build-stack.sh --tag myorg/dev:1 dotnet # build with a custom image tag
```

Run a built image (desktop on VNC `5901` / noVNC web `6901`):

```bash
docker run -d -p 5901:5901 -p 6901:6901 ackdev/devstack-java-web:<date>
# noVNC: http://localhost:6901/vnc.html  (VNC password printed at startup)
```

## Included stacks

| Stack | What's in it |
|-------|--------------|
| `java-web` | Minimal: Xfce/VNC + OpenJDK 17+21 + Maven/Gradle |
| `java-enterprise` | Eclipse, Tomcat 9, MySQL, Java toolchain, ClamAV, Firefox |
| `python-data` | Python 3, PyCharm CE, VSCodium, PostgreSQL, DBeaver |
| `node-fullstack` | Node.js LTS, VSCodium, MongoDB, Redis, Docker CLI, Chrome |
| `dotnet` | .NET SDK 8, VSCodium, PostgreSQL |
| `go-cloud` | Go, Docker CLI, VSCodium, Redis |
| `polyglot` | Java + Node + Python + Go, IntelliJ + VSCodium, PostgreSQL/Redis, Docker |

## Available components

- **base**: `core` (locale, CLI, non-root user), `security` (ClamAV + lynis)
- **desktop**: `xfce`, `vnc` (TigerVNC + noVNC), `firefox`, `chrome`
- **languages**: `java`, `node`, `python`, `go`, `rust`, `dotnet`, `php`, `ruby`
- **ides**: `eclipse`, `vscodium`, `intellij-idea-community`, `pycharm-community`, `netbeans`
- **databases**: `mysql`, `mariadb`, `postgresql`, `mongodb`, `redis`, `sqlite`, `dbeaver`
- **servers**: `tomcat`, `nginx`
- **tools**: `build-essential`, `docker-cli`, `scm`

## Compose your own stack

Create `stacks/my-stack.stack`:

```sh
STACK_NAME=my-stack
DESCRIPTION="Rust + Postgres workstation"
BASE=ubuntu:22.04
COMPONENTS="
  base/core
  desktop/xfce
  desktop/vnc
  desktop/firefox
  languages/rust
  databases/postgresql
  ides/vscodium
"
```

Then `./build-stack.sh my-stack`. You only list what you want — the builder
pulls in each component's `REQUIRES` automatically and orders them correctly
(`desktop/vnc` → `desktop/xfce` → `base/core`, IDEs after their language, etc.).

## Add a new technology (component)

Create `components/<category>/<name>/` with a `meta` and an `install.sh`. The
full contract — the hardened helper API (`apt_install`, `add_apt_repo`,
`verify_sha256`, `gpg_verify`, …) and the security rules (signed repos, verify
every download, never `--no-check-certificate`) — is in
[`components/README.md`](components/README.md).

## Build/test note

The component install scripts and the builder are validated with `bash -n`, and
every stack is validated for clean dependency resolution + Dockerfile
generation. A full `docker build` of each stack still needs to be run on a
machine with Docker + network access before publishing (image builds were not
executed in this environment). Use `./build-stack.sh --no-build <stack>` to
generate the Dockerfile, then `docker build -f build/<stack>/Dockerfile .`.

> The original monolithic build (`buildAll.sh`, `Dockerfile.base.*`) still works
> and is equivalent to the `java-enterprise` stack; the component system is the
> new, extensible path.
