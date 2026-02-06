#!/bin/bash

# --- 1. SETUP ---
rm -f /tmp/.X2-lock
rm -f /var/run/dbus/pid

if [ ! -s /etc/machine-id ]; then
  dbus-uuidgen > /etc/machine-id
fi

eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# --- 2. LOAD VARIABLES (ROBUST MODE) ---
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
fi

# Apply Defaults if variables are still empty
: "${RESOLUTION:=1280x720}"
: "${TARGET_SITE:=https://google.com}"
: "${RTMP_URL:=rtmp://localhost/live/stream}"

# CRITICAL CHECK: Stop if resolution is missing
if [ -z "$RESOLUTION" ]; then
    echo "❌ FATAL: RESOLUTION variable is empty!"
    exit 1
fi

echo "--- STREAM CONFIG ---"
echo "Target: $TARGET_SITE"
echo "Res:    $RESOLUTION"
echo "RTMP:   $RTMP_URL"

# --- 3. START XEPHYR ---
DISPLAY_NUM=:2
Xephyr $DISPLAY_NUM \
    -screen ${RESOLUTION} \
    -title "StreamSite Debugger" \
    -nolisten tcp \
    -ac \
    -dpi 96 &

echo "Waiting for Xephyr..."
for i in {1..10}; do
    if xdpyinfo -display $DISPLAY_NUM >/dev/null 2>&1; then
        echo "✅ Xephyr is ready."
        break
    fi
    sleep 0.5
done

# --- 4. START STREAM ---
ffmpeg \
    -f x11grab -video_size "$RESOLUTION" -framerate 30 -i $DISPLAY_NUM \
    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -c:v libx264 -preset ultrafast -tune zerolatency \
    -pix_fmt yuv420p \
    -g 60 -keyint_min 60 -sc_threshold 0 \
    -b:v 4500k -minrate 4500k -maxrate 4500k -bufsize 9000k \
    -c:a aac -b:a 128k \
    -f flv "$RTMP_URL" &

FFMPEG_PID=$!
echo "Streaming started with PID $FFMPEG_PID"

# --- 5. BROWSER LOOP ---
export DISPLAY=$DISPLAY_NUM

while true; do
    if ! kill -0 $FFMPEG_PID > /dev/null 2>&1; then
        echo "🚨 FFmpeg crashed! Check logs above."
        exit 1
    fi

    echo "Launching Chrome..."
    google-chrome-stable \
        --no-sandbox \
        --disable-dev-shm-usage \
        --start-maximized \
        --kiosk \
        --display=$DISPLAY_NUM \
        --window-size=${RESOLUTION//x/,} \
        --window-position=0,0 \
        --user-data-dir=/tmp/chrome-data \
        --autoplay-policy=no-user-gesture-required \
        --no-first-run \
        "$TARGET_SITE" > /dev/null 2>&1
    
    sleep 2
done
