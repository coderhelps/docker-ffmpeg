#!/bin/bash

BUILD_DIR="$HOME/ffmpeg_build"
SOURCE_DIR="$HOME/ffmpeg_sources"
INSTALL_DIR="/opt/ffmpeg"

mkdir -p $BUILD_DIR
mkdir -p $SOURCE_DIR
mkdir -p $INSTALL_DIR

export LDFLAGS="-L${BUILD_DIR}/lib"
export DYLD_LIBRARY_PATH="${BUILD_DIR}/lib"
export PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig"
export CFLAGS="-I${BUILD_DIR}/include $LDFLAGS"
export PATH="${BUILD_DIR}/bin:${INSTALL_DIR}/bin:${PATH}"
# Force PATH cache clearing
hash -r

cd ${SOURCE_DIR}
git clone --depth 1 git://github.com/yasm/yasm.git
cd yasm
autoreconf -fiv
./configure --prefix="${BUILD_DIR}" --bindir="${INSTALL_DIR}/bin"
make
make install

cd ${SOURCE_DIR}
git clone --depth 1 git://git.videolan.org/x264
cd x264
PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig" ./configure --prefix="${BUILD_DIR}" --bindir="${INSTALL_DIR}/bin" --enable-static
make
make install

cd ${SOURCE_DIR}
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${BUILD_DIR}" -DENABLE_SHARED:bool=off ../../source
make
make install

cd ${SOURCE_DIR}
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="${BUILD_DIR}" --disable-shared
make
make install

cd ${SOURCE_DIR}
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="${BUILD_DIR}" --bindir="${INSTALL_DIR}/bin" --disable-shared --enable-nasm
make
make install

cd ${SOURCE_DIR}
git clone http://git.opus-codec.org/opus.git
cd opus
autoreconf -fiv
PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig" ./configure --prefix="${BUILD_DIR}" --disable-shared
make
make install

cd ${SOURCE_DIR}
curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
tar xzvf libogg-1.3.2.tar.gz
cd libogg-1.3.2
./configure --prefix="${BUILD_DIR}" --disable-shared
make
make install

cd ${SOURCE_DIR}
curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --prefix="${BUILD_DIR}" --with-ogg="${BUILD_DIR}" --disable-shared
make
make install

cd ${SOURCE_DIR}
git clone https://git.xiph.org/theora.git #does not support depth
cd theora
./autogen.sh
./configure --prefix="${BUILD_DIR}" --disable-shared
make
make install

cd ${SOURCE_DIR}
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="${BUILD_DIR}" --disable-examples
make
make install

cd ${SOURCE_DIR}
curl -O http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PKG_CONFIG_PATH="${BUILD_DIR}/lib/pkgconfig" ./configure --prefix="${BUILD_DIR}" --extra-cflags="-I${BUILD_DIR}/include" --extra-ldflags="-L${BUILD_DIR}/lib -ldl" --bindir="${INSTALL_DIR}/bin" --pkg-config-flags="--static" \
--enable-gpl \
--enable-nonfree \
--enable-libfdk_aac \
--enable-libfreetype \
--enable-libmp3lame \
--enable-libopus \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libx264 \
--enable-libx265
make
make install

hash -r

rm -rf $BUILD_DIR
rm -rf $SOURCE_DIR

