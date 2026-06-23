# shellcheck shell=bash
# languages/dotnet - .NET SDK from Microsoft's signed apt repo.

DOTNET_SDK_VERSION="${DOTNET_SDK_VERSION:-8.0}"

log "Registering Microsoft signed apt repo (packages-microsoft-prod)"
ms_prod_deb="/tmp/packages-microsoft-prod.deb"
download "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb" "${ms_prod_deb}"
# This .deb only drops in the signed repo definition + Microsoft signing key.
dpkg -i "${ms_prod_deb}"
rm -f "${ms_prod_deb}"
apt_invalidate

log "Installing .NET SDK ${DOTNET_SDK_VERSION}"
apt_install "dotnet-sdk-${DOTNET_SDK_VERSION}"
