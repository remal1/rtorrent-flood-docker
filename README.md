# rtorrent-flood-docker

A repository for creating a docker container including rtorrent  and flood interfaces.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X2CT2SWQCP74U)


This is a completely funcional Docker image with flood,  rtorrent, libtorrent.

Based on Alpine Linux, which provides a very small size. 

Instructions: 

- Map any local port to 19939 for rtorrent 
- Map any local port to 3000 for flood access
- Map a local volume to /config (Stores configuration data, including rtorrent session directory. Consider this on SSD Disk) 
- Map a local volume to /downloads (Stores downloaded torrents)

Sample run command:

For rtorrent 0.9.6 version:

```bash
docker run -d --name=rutorrent-flood \
-v /share/Container/rutorrent-flood/config:/config \
-v /share/Container/rutorrent-flood/downloads:/downloads \
-e PGID=100 -e PUID=1000 -e TZ=Europe/Budapest \
-p 3000:3000 \
-p 19939-19939:19939-19939 \
romancin/rutorrent-flood:latest
```

For rtorrent 0.9.4 version:

```bash
docker run -d --name=rutorrent-flood \
-v /share/Container/rutorrent-flood/config:/config \
-v /share/Container/rutorrent-flood/downloads:/downloads \
-e PGID=100 -e PUID=1000 -e TZ=Europe/Budapest \
-p 3000:3000 \
-p 19939-19939:19939-19939 \
romancin/rutorrent-flood:0.9.4
```

Remember editing `/config/rtorrent/rtorrent.rc` with your own settings, especially your watch subfolder configuration.
