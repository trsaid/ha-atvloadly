#!/bin/sh
set -e

echo "=== ATVLoadly Home Assistant Add-on ==="

# ------------------------------------
# 1. Setup data directories
# ------------------------------------
mkdir -p /data/lockdown
mkdir -p /data/PlumeImpactor
mkdir -p "$HOME/.config"

# Symlink lockdown directory
if [ ! -e "/var/lib/lockdown" ]; then
    ln -s /data/lockdown /var/lib/lockdown
fi

# Symlink PlumeImpactor config
if [ ! -e "$HOME/.config/PlumeImpactor" ]; then
    ln -s /data/PlumeImpactor "$HOME/.config/PlumeImpactor"
fi

# Copy anisette libraries if present
if [ -d "/keep/lib" ]; then
    rm -rf /data/PlumeImpactor/lib
    cp -rf /keep/lib /data/PlumeImpactor/lib
    rm -rf /keep/lib
fi

# Copy default config if not present
if [ ! -f "/data/config.yaml" ]; then
    if [ -f "/keep/config.yaml" ]; then
        cp /keep/config.yaml /data/config.yaml
    fi
fi

# (D-Bus startup removed: Avahi configured to run without D-Bus)

# 3. Start Avahi daemon
# ------------------------------------
echo "Starting Avahi daemon..."
mkdir -p /var/run/avahi-daemon

# Ensure avahi user exists (should be created by package install)
if ! id avahi >/dev/null 2>&1; then
    echo "Warning: avahi user not found, creating..."
    useradd -r -s /usr/sbin/nologin avahi 2>/dev/null || true
fi

# Clean stale pid
rm -f /var/run/avahi-daemon/pid

# Start avahi-daemon in the background without dbus
avahi-daemon --no-chroot --no-drop-root &
sleep 1
echo "Avahi daemon started."

# ------------------------------------
# 4. Start usbmuxd
# ------------------------------------
echo "Starting usbmuxd..."
if [ -x /etc/init.d/usbmuxd ]; then
    /etc/init.d/usbmuxd start || echo "Warning: usbmuxd failed to start (USB device may not be connected)"
else
    echo "Warning: usbmuxd init script not found, trying direct start..."
    usbmuxd -f -v &
fi
sleep 1

# ------------------------------------
# 5. Start ATVLoadly
# ------------------------------------
echo "Starting ATVLoadly on port ${SERVICE_PORT:-80}..."
exec /usr/bin/atvloadly server -p "${SERVICE_PORT:-80}" -c /data/config.yaml
