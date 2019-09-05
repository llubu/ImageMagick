HOME_DIR=$(pwd)
LIB_MAGICKWAND_PATH=$HOME_DIR/3rdparty/ImageMagick/MagickWand/.libs/
LIB_MAGICKCORE_PATH=$HOME_DIR/3rdparty/ImageMagick/MagickCore/.libs/
LIB_MAGICKWAND=libMagickWand-7.Q16HDRI.so.6
LIB_MAGICKCORE=libMagickCore-7.Q16HDRI.so.6
CONFIG=release
ARCH=x86_64

cd $HOME_DIR/3rdparty/ImageMagick
if [ ! -f "$HOME_DIR/3rdparty/ImageMagick/Makefile" ]; then
	./configure
fi

make -j
cd $HOME_DIR

if [ -f "$LIB_MAGICKWAND_PATH/$LIB_MAGICKWAND" ] && [ -f "$LIB_MAGICKCORE_PATH/$LIB_MAGICKCORE" ]; then
	cp $LIB_MAGICKWAND_PATH/$LIB_MAGICKWAND $HOME_DIR/$CONFIG-$ARCH/
	cp $LIB_MAGICKCORE_PATH/$LIB_MAGICKCORE $HOME_DIR/$CONFIG-$ARCH/

	if [ ! -L "$HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKWAND" ]; then
		ln -s $HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKWAND $HOME_DIR/$CONFIG-$ARCH/libMagickWand-7.Q16HDRI.so
	fi

	if [ ! -L "$HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKCORE" ]; then
		ln -s $HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKCORE $HOME_DIR/$CONFIG-$ARCH/libMagickCore-7.Q16HDRI.so
	fi
fi

