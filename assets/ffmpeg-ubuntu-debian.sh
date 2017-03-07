# FFmpeg compilation for Ubuntu and Debian.
# Alvaro Bustos. Thanks to Hunter.
# Updated 24-2-2017

sudo apt-get update
sudo apt-get -y --force-yes install autoconf automake build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev mercurial cmake libx264-dev libfdk-aac-dev libmp3lame-dev

# Create a directory for sources.
SOURCES=$(mkdir ~/ffmpeg_sources)
cd ~/ffmpeg_sources

# Download the necessary sources.
wget ftp://ftp.gnome.org/mirror/xbmc.org/build-deps/sources/lame-3.99.5.tar.gz
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
# git clone --depth 1 git://git.videolan.org/x264
curl -#LO ftp://ftp.videolan.org/pub/x264/snapshots/last_stable_x264.tar.bz2
hg clone https://bitbucket.org/multicoreware/x265
wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master
# git clone http://git.opus-codec.org/opus.git
wget http://downloads.xiph.org/releases/opus/opus-1.1.4.tar.gz
# git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.6.1.tar.bz2
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
#git clone --depth 1 git://source.ffmpeg.org/ffmpeg
# wget http://ffmpeg.org/releases/ffmpeg-3.1.1.tar.gz

# Unpack files
for file in `ls ~/ffmpeg_sources/*.tar.*`; do
tar -xvf $file
done

cd yasm-*/
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && make && sudo make install && make distclean; cd ..

cd x264-*/
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl && PATH="$HOME/bin:$PATH" make && sudo make install && make distclean; cd ..

cd x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source && make && sudo make install && make distclean; cd ~/ffmpeg_sources

cd mstorsjo-fdk-aac*
autoreconf -fiv && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && make && sudo make install && make distclean; cd ..

cd lame-*/
./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared && make && sudo make install && make distclean; cd ..

cd opus-*/
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && make && sudo make install && make distclean; cd ..

cd libvpx-*/
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests && PATH="$HOME/bin:$PATH" make && sudo make install && make clean; cd ..

cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --pkg-config-flags="--static" --extra-cflags="-I$HOME/ffmpeg_build/include"  --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree && PATH="$HOME/bin:$PATH" make && sudo make install && make distclean && hash -r; cd ..

cd ~/bin
cp ffmpeg ffprobe ffserver vsyasm x264 yasm ytasm /usr/local/bin

cd ~/ffmpeg_build/bin
cp lame x265 /usr/local/bin

echo "FFmpeg Compilation is Finished!"

