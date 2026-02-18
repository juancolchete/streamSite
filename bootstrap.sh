touch .env
cp .env .env-bak
rm .env
touch .env
cp nginx.conf nginx-bak.conf
rm nginx.conf
cp nginx-sample.conf nginx.conf
sed -i -e 's|push rtmp://YOUR_STREAM_URL;||g' nginx.conf
sed -i -e 's|push rtmp://YOUR_STREAM_URL_2;||g' nginx.conf
touch nginx.conf
rm nginx.conf
cp nginx-sample.conf nginx.conf
if [[ ! -z "$RTMP_SERVER_1" ]]; then
  echo "RTMP SERVER 1:"
  read RTMP_SERVER_1
fi
sed -i -e 's|YOUR_STREAM_URL_1|$RTMP_SERVER_1|g' nginx.conf
if [[ ! -z "$RTMP_SERVER_2" ]]; then
  echo "RTMP SERVER 2:"
  read RTMP_SERVER_2
fi
sed -i -e 's|YOUR_STREAM_URL_2|$RTMP_SERVER_2|g' nginx.conf 
docker compose up -d
echo "RTMP_URL=rtmp://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-rtmp)/live" >> .env
echo "TARGET_SITE=https://coinmarketcap.com" >> .env
echo "RESOLUTION=1920x1080" >> .env
docker compose up -d
