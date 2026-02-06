#!/usr/bin/env bash

# --- 1. PREPARE XAUTHORITY ---
# We run these as your normal user to capture your specific display cookie.
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# Create the file
touch $XAUTH

# Extract credentials for the current display
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Allow local access (fix for NixOS/Strict permissions)
xhost +local:

# --- 2. CLEANUP (With Sudo) ---
# Check if container exists using sudo
if [ "$(sudo docker ps -aq -f name=streamSite)" ]; then
    echo "Stopping old container..."
    sudo docker rm -f streamSite > /dev/null
fi

# --- 3. RUN (With Sudo) ---
echo "Starting StreamSite with Xephyr..."
echo "Display: $DISPLAY"

sudo docker run -d \
  --name streamSite \
  --net=host \
  --env="DISPLAY" \
  --env="XAUTHORITY=$XAUTH" \
  --volume="$XSOCK:$XSOCK:rw" \
  --volume="$XAUTH:$XAUTH:rw" \
  --shm-size=2g \
  -v "$(pwd)/.env:/app/.env" \
  streamsite

# --- 4. LOGS (With Sudo) ---
echo "Container started. Tailing logs..."
sleep 2
sudo docker logs -f streamSite
