FROM ubuntu:22.04

# 1. Install dependencies
# ADDED: xvfb (Required for headless mode)
RUN apt-get update && apt-get install -y \
    wget gnupg ffmpeg tini \
    dbus dbus-x11 dos2unix uuid-runtime \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Google Chrome Stable
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

RUN dbus-uuidgen > /etc/machine-id

# 3. Setup Script
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh
RUN mkdir -p /var/run/dbus

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
