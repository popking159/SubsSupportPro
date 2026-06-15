#!/bin/sh

# ============================================================
# SubsSupportPro Installer (Simple Version)
# ============================================================

echo "===================================================="
echo "        SubsSupportPro INSTALLER STARTED            "
echo "===================================================="

# ---------------------------
# Remove old version
# ---------------------------
echo "[INFO] Removing old SubsSupportPro..."
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/SubsSupportPro

# ---------------------------
# Remove opkg package if exists
# ---------------------------
STATUS_FILE="/var/lib/opkg/status"
PACKAGE="enigma2-plugin-extensions-subssupportpro"

if [ -f "$STATUS_FILE" ]; then
    if grep -q "$PACKAGE" "$STATUS_FILE"; then
        opkg remove $PACKAGE > /dev/null 2>&1
    fi
fi

# ---------------------------
# Download plugin
# ---------------------------
TMP_FILE="/var/volatile/tmp/main.tar.gz"

echo "[INFO] Downloading plugin..."

wget -q --no-check-certificate \
"https://github.com/popking159/SubsSupportPro/raw/refs/heads/main/main.tar.gz" \
-O $TMP_FILE

if [ ! -f "$TMP_FILE" ]; then
    echo "[ERROR] Download failed!"
    exit 1
fi

echo "[INFO] Extracting..."
tar -xzf $TMP_FILE -C /

rm -f $TMP_FILE

# ---------------------------
# Finish
# ---------------------------
sync

echo "===================================================="
echo "       SubsSupportPro INSTALLATION DONE            "
echo "===================================================="
echo "Restarting Enigma2..."

killall -9 enigma2

exit 0