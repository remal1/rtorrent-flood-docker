FROM lsiobase/alpine:3.8

MAINTAINER romancin

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BUILD_CORES
LABEL build_version="Romancin version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package version
ARG MEDIAINF_VER="18.05"
ARG RTORRENT_VER="0.9.6"
ARG LIBTORRENT_VER="0.13.6"
ARG CURL_VER="7.61.0"
ARG FLOOD_VER="1.0.0"

# set env
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV FLOOD_SECRET=flood
ENV CONTEXT_PATH=/
ENV PUID=1000
ENV PGID=100
ENV TZ=Europe/Budapest
    
RUN NB_CORES=${BUILD_CORES-`getconf _NPROCESSORS_CONF`} && \
 apk add --no-cache \
	bash-completion \
        ca-certificates \
        fcgi \
        ffmpeg \
        geoip \
        gzip \
        logrotate \
        nginx \
        dtach \
        tar \
        unrar \
        unzip \
        sox \
        wget \
        zlib \
        zlib-dev \
        libxml2-dev \
        git \
        libressl \
        binutils \
        findutils \
		ncurses \
        zip && \

# install build packages
 apk add --no-cache --virtual=build-dependencies \
        autoconf \
        automake \
        cppunit-dev \
        perl-dev \
        file \
        g++ \
        gcc \
        libtool \
        make \
        ncurses-dev \
        build-base \
        libtool \
        subversion \
        cppunit-dev \
        linux-headers \
        curl-dev \
        libressl-dev && \
		xz && \

# compile curl to fix ssl for rtorrent
cd /tmp && \
mkdir curl && \
cd curl && \
wget -qO- https://curl.haxx.se/download/curl-${CURL_VER}.tar.gz | tar xz --strip 1 && \
./configure --with-ssl && make -j ${NB_CORES} && make install && \
ldconfig /usr/bin && ldconfig /usr/lib && \

# compile xmlrpc-c
cd /tmp && \
svn checkout http://svn.code.sf.net/p/xmlrpc-c/code/stable xmlrpc-c && \
cd /tmp/xmlrpc-c && \
./configure --with-libwww-ssl --disable-wininet-client --disable-curl-client --disable-libwww-client --disable-abyss-server --disable-cgi-server && make -j ${NB_CORES} && make install && \

# compile libtorrent
apk add -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main -U cppunit-dev==1.13.2-r1 cppunit==1.13.2-r1 && \
cd /tmp && \
mkdir libtorrent && \
cd libtorrent && \
wget -qO- https://github.com/rakshasa/libtorrent/archive/${LIBTORRENT_VER}.tar.gz | tar xz --strip 1 && \
./autogen.sh && ./configure && make -j ${NB_CORES} && make install && \

# compile rtorrent
cd /tmp && \
mkdir rtorrent && \
cd rtorrent && \
wget -qO- https://github.com/rakshasa/rtorrent/archive/${RTORRENT_VER}.tar.gz | tar xz --strip 1 && \
./autogen.sh && ./configure --with-xmlrpc-c && make -j ${NB_CORES} && make install && \

# compile mediainfo packages
 curl -o \
 /tmp/libmediainfo.tar.gz -L \
        "http://mediaarea.net/download/binary/libmediainfo0/${MEDIAINF_VER}/MediaInfo_DLL_${MEDIAINF_VER}_GNU_FromSource.tar.gz" && \
 curl -o \
 /tmp/mediainfo.tar.gz -L \
        "http://mediaarea.net/download/binary/mediainfo/${MEDIAINF_VER}/MediaInfo_CLI_${MEDIAINF_VER}_GNU_FromSource.tar.gz" && \
 mkdir -p \
        /tmp/libmediainfo \
        /tmp/mediainfo && \
 tar xf /tmp/libmediainfo.tar.gz -C \
        /tmp/libmediainfo --strip-components=1 && \
 tar xf /tmp/mediainfo.tar.gz -C \
        /tmp/mediainfo --strip-components=1 && \

 cd /tmp/libmediainfo && \
        ./SO_Compile.sh && \
 cd /tmp/libmediainfo/ZenLib/Project/GNU/Library && \
        make install && \
 cd /tmp/libmediainfo/MediaInfoLib/Project/GNU/Library && \
        make install && \
 cd /tmp/mediainfo && \
        ./CLI_Compile.sh && \
 cd /tmp/mediainfo/MediaInfo/Project/GNU/CLI && \
        make install && \

# install flood webui
 apk add --no-cache \
     python \
     nodejs \
     nodejs-npm && \

 mkdir /usr/flood && \
 cd /usr/flood && \
 git clone https://github.com/jfurrow/flood . && \
 cp config.template.js config.js && \
 npm install -g node-gyp && \
 npm install && \
 npm cache clean --force && \
 npm run build && \
 rm config.js && \

# cleanup
 apk del --purge \
        build-dependencies && \
 apk del -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main cppunit-dev && \
 rm -rf \
        /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 19939 3000
VOLUME /config /downloads
