#!/bin/bash

# --- 1. SETUP & CLEANUP ---
rm -f /tmp/.X99-lock
rm -f /var/run/dbus/pid

# Generate machine-id (Prevents Chrome crashes)
if [ ! -s /etc/machine-id ]; then
  dbus-uuidgen > /etc/machine-id
fi

# Start DBus (Fixes "Failed to connect to bus" errors)
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Load Variables
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

# Defaults
: "${RESOLUTION:=1280x720}"
: "${TARGET_SITE:=https://google.com}"
: "${RTMP_URL:=rtmp://localhost/live/stream}"

echo "--- HEADLESS CONFIG ---"
echo "Target: $TARGET_SITE"
echo "Res:    $RESOLUTION"

# --- 2. START VIRTUAL DISPLAY (Xvfb) ---
# We use :99 as the internal invisible screen
export DISPLAY=:99

Xvfb :99 -screen 0 "${RESOLUTION}x24" -ac -nolisten tcp +extension RANDR &

echo "Waiting for Xvfb..."
for i in {1..10}; do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "✅ Xvfb is ready."
        break
    fi
    sleep 0.5
done

# --- 3. START STREAM (YouTube Optimized) ---
# Includes silent audio, high bitrate, and keyframes
ffmpeg \
    -f x11grab -video_size "$RESOLUTION" -framerate 30 -i :99 \
    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -c:v libx264 -preset ultrafast -tune zerolatency \
    -pix_fmt yuv420p \
    -g 60 -keyint_min 60 -sc_threshold 0 \
    -b:v 4500k -minrate 4500k -maxrate 4500k -bufsize 9000k \
    -c:a aac -b:a 128k \
    -f flv "$RTMP_URL" &

FFMPEG_PID=$!
echo "Streaming started with PID $FFMPEG_PID"

# --- 4. BROWSER LOOP ---
while true; do
    if ! kill -0 $FFMPEG_PID > /dev/null 2>&1; then
        echo "🚨 FFmpeg crashed! Check your RTMP URL."
        exit 1
    fi

    echo "Launching Chrome (Headless)..."
    
    # We run Chrome on the invisible :99 display
    google-chrome-stable \
        --no-sandbox \
        --disable-dev-shm-usage \
        --start-maximized \
        --kiosk \
        --display=:99 \
        --window-size=${RESOLUTION//x/,} \
        --window-position=0,0 \
        --user-data-dir=/tmp/chrome-data \
        --autoplay-policy=no-user-gesture-required \
        --no-first-run \
        --disable-sync \
        --disable-logging \
        --log-level=3 \
        "$TARGET_SITE" > /dev/null 2>&1
    
    sleep 2
done
