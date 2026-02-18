# streamsite
Your tool to multi stream a site content without complication.

## Run fast
```
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
```

## Configuration

```bash
cp .env-sample .env
```

Change `TARGET_SITE` to the site that you want to stream.

```bash
cp nginx-sample.conf nginx.conf
```

Change this bellow part to your rtmp servers you can add more than two, if you want just one deline one line and just replace YOUR_STREAM_URL if you want two just replace YOUR_STREAM_URL with your urls, and if you want more just duplciate de line and edit ist value 

```
push rtmp://YOUR_STREAM_URL;
push rtmp://YOUR_STREAM_URL;
```

## Get container IP to pass in RTMP_URL on .env file
```
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-rtmp
```
