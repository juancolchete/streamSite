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
echo "Stream KEY 1"
read STREAM_KEY_1
sed -i -e 's|YOUR_STREAM_URL_1|$STREAM_KEY_1|g' nginx.conf
echo "Stream KEY 2"
read STREAM_KEY_2
sed -i -e 's|YOUR_STREAM_URL_2|$STREAM_KEY_2|g' nginx.conf 
docker compose up -d
echo "RTMP_URL=rtmp://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-rtmp)/live" >> .env
echo "TARGET_SITE=https://coinmarketcap.com" >> .env
echo "RESOLUTION=1920x1080" >> .env
docker compose up -d
