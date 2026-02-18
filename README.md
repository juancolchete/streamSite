# streamsite
Your tool to multi stream a site content without complication.

## Run fast
```
bash bootstrap.sh
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
