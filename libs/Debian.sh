#!/bin/bash
FINAL_OUT_DIR=libs
HOME_PATH=$(pwd)
PKG_NAME=ImageMagick-libs

cd ..
make distclean
./configure
make clean
make -j

cd -

# Create package subdirectory. Install at /opt/bin/ImageMagick
INSTALL_PATH=/usr/local/lib

#Cleanup resources to avoid any stale data
rm -rf package
rm -rf $FINAL_OUT_DIR

#Fetch all the header files from MagickWand and MagickCore source
mkdir -p $FINAL_OUT_DIR

cp ../MagickWand/.libs/*.so.6.0.0 $FINAL_OUT_DIR/.
cp ../MagickCore/.libs/*.so.6.0.0 $FINAL_OUT_DIR/.

#Create Symlinks 
cd $FINAL_OUT_DIR
rm -rf libMagickWand-7.Q16HDRI.so
rm -rf libMagickCore-7.Q16HDRI.so
ln -s libMagickWand-7.Q16HDRI.so.6.0.0 libMagickWand-7.Q16HDRI.so 
ln -s libMagickCore-7.Q16HDRI.so.6.0.0 libMagickCore-7.Q16HDRI.so
cd -

DATA_PKG_PATH=package/debian/$INSTALL_PATH/$PKG_NAME
mkdir -p $DATA_PKG_PATH
cp -r $FINAL_OUT_DIR/* $DATA_PKG_PATH/

# Dest format: package/debian/DEBIAN/[control, md5sum, postinst, prerm files]
cp -r DEBIAN package/debian/

# Create the .deb (debian-binary, control.tar.gz, data.tar.xz)
cd package
dpkg-deb --verbose --build debian
mv debian.deb $PKG_NAME.deb

cd $HOME_PATH
rm -rf $FINAL_OUT_DIR
git checkout -- DEBIAN/postinst

