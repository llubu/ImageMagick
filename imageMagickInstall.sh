HOME_DIR=.
LIB_MAGICKWAND_PATH=$HOME_DIR/3rdparty/ImageMagick/MagickWand/.libs/
LIB_MAGICKCORE_PATH=$HOME_DIR/3rdparty/ImageMagick/MagickCore/.libs/
LIB_MAGICKWAND=libMagickWand-7.Q16HDRI.so.6
LIB_MAGICKCORE=libMagickCore-7.Q16HDRI.so.6
CONFIG=$1
ARCH=$2

cd $HOME_DIR/3rdparty/ImageMagick
if [ ! -f "$HOME_DIR/3rdparty/ImageMagick/Makefile" ]; then
	./configure
fi

make -j
cd -

if [ -f "$LIB_MAGICKWAND_PATH/$LIB_MAGICKWAND" ] && [ -f "$LIB_MAGICKCORE_PATH/$LIB_MAGICKCORE" ]; then
	rm -rf $HOME_DIR/$CONFIG-$ARCH/*Magick*
	cp $LIB_MAGICKWAND_PATH/$LIB_MAGICKWAND $HOME_DIR/$CONFIG-$ARCH/
	cp $LIB_MAGICKCORE_PATH/$LIB_MAGICKCORE $HOME_DIR/$CONFIG-$ARCH/

	cd $HOME_DIR/$CONFIG-$ARCH

	if [ ! -L "$HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKWAND" ]; then
		ln -s $LIB_MAGICKWAND libMagickWand-7.Q16HDRI.so
	fi

	if [ ! -L "$HOME_DIR/$CONFIG-$ARCH/$LIB_MAGICKCORE" ]; then
		ln -s $LIB_MAGICKCORE libMagickCore-7.Q16HDRI.so
	fi

	cd -
fi


