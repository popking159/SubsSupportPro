#!/bin/sh

# =========================================================================
# CONFIGURATION (DreamOS Version)
# =========================================================================
PLUGIN_NAME="SubsSupportPro"
USERNAME="popking159"
REPO="SubsSupportPro"

# DreamOS uses 'apt'. Core python modules (json, codecs, xmlrpc, etc.) are 
# already built into the base system. We only need the external libraries.
DEPENDS="python-requests python-beautifulsoup python-six python-twisted-web unrar"

# Target the DreamOS specific payload
PLUGIN_URL="https://github.com/${USERNAME}/${REPO}/raw/refs/heads/main/main_dreamos.tar.gz"

TMP_DIR="/tmp"
TMP_FILE="$TMP_DIR/main_dreamos_install.tar.gz"

log() {
    echo "$1"
}

is_pkg_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed" && return 0
    return 1
}

restart_enigma2() {
    log "[INFO] Restarting DreamOS UI..."
    sleep 2
    systemctl restart enigma2
}

echo "===================================================="
echo "      $PLUGIN_NAME DREAMOS INSTALLER UTILITY        "
echo "===================================================="

log "[INFO] Updating apt package feeds..."
apt-get update >/dev/null 2>&1 || log "[WARN] apt update failed, continuing..."

log "[INFO] Verifying required DreamOS dependencies..."
for pkg in $DEPENDS; do
    if is_pkg_installed "$pkg"; then
        log "[OK] Already installed: $pkg"
    else
        log "[INFO] Downloading and installing: $pkg"
        DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg" >/dev/null 2>&1
        
        if is_pkg_installed "$pkg"; then
            log "[OK] Successfully installed: $pkg"
        else
            log "[ERROR] Dependency '$pkg' could not be installed! Aborting."
            exit 1
        fi
    fi
done

log "[INFO] Downloading DreamOS plugin archive..."
rm -f "$TMP_FILE"
wget -q --no-check-certificate "$PLUGIN_URL" -O "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
    log "[ERROR] Download failed or file is empty!"
    rm -f "$TMP_FILE"
    exit 1
fi

log "[INFO] Extracting payload to system paths..."
tar -xzf "$TMP_FILE" -C /
if [ $? -ne 0 ]; then
    log "[ERROR] Extraction failed!"
    rm -f "$TMP_FILE"
    exit 1
fi

rm -f "$TMP_FILE"
sync

echo "===================================================="
echo "          $PLUGIN_NAME INSTALLATION COMPLETE        "
echo "===================================================="

restart_enigma2
exit 0