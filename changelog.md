## Changelog of the Docker headless Developer Java Eclipse Tomcat MySQL VNC images

### Version 2.0.0 (2026-06-23) — Technology refresh & security hardening

> NOTE: This is a source-level modernization. The chained base images
> (`base-1` → `base-devtools` → `base-xfce` → final) MUST be rebuilt and
> functionally tested via `./buildAll.sh` before publishing — the build was not
> run as part of this change.

**Technology freshened (all EOL components updated):**
* Base OS: Ubuntu 18.04 (EOL Apr 2023) → **Ubuntu 22.04 LTS**
* JDK: OpenJDK 8 → **OpenJDK 17 (LTS)**
* Apache Tomcat: 9.0.36 → **9.0.119** (pinned against `archive.apache.org` for reproducibility)
* MySQL Community Server: 8.0.15 → **8.0.46** (latest 8.0.x)
* Eclipse IDE for Enterprise Java: 2019-03 → **2026-03 R**
* noVNC: 1.0.0 → **1.7.0**; websockify: 0.6.1 → **0.13.0**
* TigerVNC: 1.8.0 → **1.16.1**
* Image tag: `2020-06-16-r1` → `2026-06-23-r1`

**Security fixes:**
* **Re-enabled signature/checksum enforcement** in the Tomcat and MySQL
  installers — verification failures were previously logged but the `exit 1`
  was commented out, so a tampered artifact would still be installed.
* **Removed `--no-check-certificate`** from the Tomcat download path (it
  disabled TLS verification); replaced the obsolete `checker.apache.org` lookup
  with the official `.sha512` published next to the artifact over HTTPS.
* GPG keys now imported from official HTTPS sources (Apache `KEYS`, MySQL 2023
  release key) instead of single hard-coded key ids fetched over plaintext
  `hkp://` keyservers.
* **Fixed dead `dl.bintray.com` TigerVNC URL** (Bintray shut down May 2021) →
  TigerVNC project on SourceForge over HTTPS.
* **Google Chrome** now installed from Google's signed APT repository instead of
  an unverified one-off `.deb` download (previously flagged Mirai by ClamAV).
* **Firefox** installed from Mozilla's signed APT repo (the Ubuntu 22.04
  `firefox`/`chromium-browser` apt packages are snap shims that do not work in a
  container); removed the broken Chromium snap packages.
* ClamAV signature DB downloads switched from `http://` to `https://`.
* Fixed a latent shell bug in the Eclipse installer where an unquoted `&` in the
  checksum URL backgrounded `wget` and ran `type=sha512` as a command, so the
  SHA-512 check never actually ran.
* Removed EOL Python 2 (`python-numpy` → `python3-numpy`) and obsolete `cvs`/
  `telnet` packages.

### Version 1.0.0:
* Initial Build