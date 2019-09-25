#!/bin/bash
FINAL_OUT_DIR=headers
HOME_PATH=$(pwd)
PKG_NAME=ImageMagick-devel

cd ..
if [ -f "Makefile"] then
        make distclean
fi
./configure
make clean
make -j
cd -
# Create package subdirectory. Install at /opt/bin/ImageMagick
INSTALL_PATH=/usr/local/include

#Cleanup resources to avoid any stale data
rm -rf package
rm -rf $FINAL_OUT_DIR

#Fetch all the header files from MagickWand and MagickCore source
mkdir -p $FINAL_OUT_DIR
mkdir -p $FINAL_OUT_DIR/MagickWand/
mkdir -p $FINAL_OUT_DIR/MagickCore/

cp -r ../MagickWand/*.h $FINAL_OUT_DIR/MagickWand/ 
cp -r ../MagickCore/*.h $FINAL_OUT_DIR/MagickCore/ 

rm -rf $FINAL_OUT_DIR/MagickCore/*.libs
rm -rf $FINAL_OUT_DIR/MagickCore/*.deps
rm -rf $FINAL_OUT_DIR/MagickWand/*.libs
rm -rf $FINAL_OUT_DIR/MagickWand/*.deps

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

