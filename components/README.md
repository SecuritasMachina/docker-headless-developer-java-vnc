# Components

A **component** is a single, self-contained technology (a language runtime, an
IDE, a database, a server, a tool, or a piece of the base desktop). Stacks are
assembled from components by [`build-stack.sh`](../build-stack.sh).

```
components/<category>/<name>/
  meta            # required: component metadata (KEY=VALUE, sourced as shell)
  install.sh      # required: installs the technology during `docker build`
  packages.lst    # optional: apt packages, one per line (# comments allowed)
  desktop/        # optional: *.desktop launchers shown on the user's Desktop
```

A component's **id** is its path under `components/`, e.g. `languages/go`,
`ides/vscodium`, `databases/postgresql`.

## `meta`

Sourced as shell, so use `KEY="value"` form:

```sh
NAME="Go"
CATEGORY=languages
DESCRIPTION="Go toolchain (latest stable) + common tooling"
REQUIRES="base/core"          # space-separated component ids (may be empty)
```

`REQUIRES` is resolved transitively and topologically ordered by the builder, so
a component never runs before its dependencies. Almost everything should require
at least `base/core`. Desktop apps (IDEs, browsers) should also require
`desktop/xfce` so a window manager exists for their launchers.

## `install.sh`

Runs **as root during the image build**, sourced by
[`stackbuild/run-component.sh`](../stackbuild/run-component.sh) with the shared
[`helpers.sh`](../stackbuild/helpers.sh) API already loaded. Keep it small and
lean on the helpers — they enforce the project's security practices:

| Helper | Purpose |
|--------|---------|
| `log` / `warn` / `die` | structured output; `die` aborts the build |
| `retry <cmd>` | retry a flaky/network command |
| `apt_install <pkgs…>` | install apt packages (no recommends, update-once) |
| `add_apt_repo <name> <key_url> <deb_line>` | add a **signed** third-party apt repo |
| `download <url> <out>` | `wget` with retry |
| `verify_sha256` / `verify_sha512 <file> <hex>` | checksum gate (aborts on mismatch) |
| `gpg_verify <sig> <file> <keys_url>` | detached-signature gate (aborts on failure) |

Conventions / rules:

- **Always verify** anything downloaded outside apt: pin a checksum
  (`verify_sha256`) or verify a signature (`gpg_verify`). Never `--no-check-certificate`.
- Prefer **signed apt repos** (`add_apt_repo`) over one-off `.deb` downloads.
- `$COMPONENT_DIR` points at the component's own directory (for shipped assets).
- Pin a version in a single `*_VERSION=` variable at the top so bumps are one-line.
- Be idempotent where practical; leave no apt cache (the builder runs `finalize.sh`).
- `packages.lst` is convenience only — `install.sh` must `apt_install $(...)` it
  itself if it wants those packages (the builder does not auto-install it).

## Categories

`base`, `desktop`, `languages`, `ides`, `databases`, `servers`, `tools`.

See [`base/core`](base/core/), [`desktop/xfce`](desktop/xfce/) and
[`languages/java`](languages/java/) as reference implementations.
