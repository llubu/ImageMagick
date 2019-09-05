HOME_DIR=$(pwd)
CONFIG=release
ARCH=x86_64
FILE=$HOME_DIR/3rdparty/ImageMagick/Makefile
cd $HOME_DIR/3rdparty/ImageMagick
if [ -f "$FILE" ]; then
	make clean
	make distclean
fi
cd $HOME_DIR
rm -rf $HOME_DIR/$CONFIG-$ARCH/*.so*

