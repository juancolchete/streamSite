#!/bin/bash

touch .env .env-temp
source .env-temp

cp .env .env-bak
> .env

cp nginx.conf nginx-bak.conf
cp nginx-sample.conf nginx.conf

sed -i -e 's|push rtmp://YOUR_STREAM_URL;||g' nginx.conf
sed -i -e 's|push rtmp://YOUR_STREAM_URL_2;||g' nginx.conf

if [ -z "$RTMP_SERVER_LIST" ]; then
    echo "No existing servers found. Let's configure them."
    read -p "How many RTMP servers would you like to add? " QUANTITY

    if ! [[ "$QUANTITY" =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number."
        exit 1
    fi

    RTMP_SERVERS=()
    for ((i=1; i<=QUANTITY; i++)); do
        read -p "Enter URL for Server #$i: " SERVER_URL
        RTMP_SERVERS+=("$SERVER_URL")
    done

    EXPORT_VAL=$(IFS="|"; echo "${RTMP_SERVERS[*]}")
    echo "RTMP_SERVER_LIST=\"$EXPORT_VAL\"" > .env-temp
else
    echo "Found existing servers in .env-temp. Skipping manual entry."
    IFS="|" read -r -a RTMP_SERVERS <<< "$RTMP_SERVER_LIST"
fi

PUSH_BLOCK=""
for URL in "${RTMP_SERVERS[@]}"; do
    PUSH_BLOCK+="        push $URL;\n"
done

sed -i "s!RTMP_SERVERS_HERE!$PUSH_BLOCK!" nginx.conf

docker compose up -d

echo "RTMP_URL=rtmp://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-rtmp)/live" >> .env
echo "TARGET_SITE=https://coinmarketcap.com" >> .env
echo "RESOLUTION=1920x1080" >> .env

docker compose up -d
