HOME_DIR=.
CONFIG=$1
ARCH=$2
FILE=$HOME_DIR/3rdparty/ImageMagick/Makefile
LIB_MAGICKWAND=libMagickWand-7.Q16HDRI.so.6
LIB_MAGICKCORE=libMagickCore-7.Q16HDRI.so.6
cd $HOME_DIR/3rdparty/ImageMagick
if [ -f "$FILE" ]; then
	make clean
	make distclean
fi
cd -
rm -rf $HOME_DIR/$CONFIG-$ARCH/*Magick*
