HOME_DIR=.
CONFIG=release
ARCH=x86_64
FILE=$HOME_DIR/3rdparty/ImageMagick/Makefile
LIB_MAGICKWAND=libMagickWand-7.Q16HDRI.so.6
LIB_MAGICKCORE=libMagickCore-7.Q16HDRI.so.6
cd $HOME_DIR/3rdparty/ImageMagick
if [ -f "$FILE" ]; then
	make clean
	make distclean
fi
cd -
rm -rf $HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKWAND
rm -rf $HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKCORE
rm -rf $HOME_DIR/$CONFIG-$ARCH/libMagickCore-7.Q16HDRI.so
rm -rf $HOME_DIR/$CONFIG-$ARCH/libMagickWand-7.Q16HDRI.so
