#!/bin/bash
FINAL_OUT_DIR=imagemagickDeb
HOME_PATH=$(pwd)

make clean
make -j

# Create package subdirectory (binaries, roms). Install at /opt/bin/skillet
INSTALL_PATH=/opt/bin/

#Fetch all the header files from MagickWand and MagickCore source
rm -rf imagemagickDeb/MagickWand/*
rm -rf imagemagickDeb/MagickCore/*
rm -rf imagemagickDeb/*.so

cp -r MagickWand/*.h imagemagickDeb/MagickWand/ 
cp -r MagickCore/*.h imagemagickDeb/MagickCore/ 
cp MagickWand/.libs/*.so.6.0.0 imagemagickDeb/.
cp MagickCore/.libs/*.so.6.0.0 imagemagickDeb/.

#Create Symlinks to be used by skillet
cd imagemagickDeb
ln -s libMagickWand-7.Q16HDRI.so.6.0.0 libMagickWand-7.Q16HDRI.so 
ln -s libMagickCore-7.Q16HDRI.so.6.0.0 libMagickCore-7.Q16HDRI.so
cd -

rm -rf imagemagickDeb/MagickCore/*.libs
rm -rf imagemagickDeb/MagickCore/*.deps
rm -rf imagemagickDeb/MagickWand/*.libs
rm -rf imagemagickDeb/MagickWand/*.deps

PKG_INCLUDE=($FINAL_OUT_DIR/*)

DATA_PKG_PATH=package/debian/$INSTALL_PATH/$PKG_NAME
echo $DATA_PKG_PATH
mkdir -p $DATA_PKG_PATH
for item in ${PKG_INCLUDE[@]}; do
	cp -r $item $DATA_PKG_PATH
done

# Dest format: package/debian/DEBIAN/[control, md5sum, postinst, prerm files]
rm -rf package/debian/DEBIAN
cp -r DEBIAN package/debian/

# Create the .deb (debian-binary, control.tar.gz, data.tar.xz)
cd package
rm -rf *.deb
dpkg-deb --verbose --build debian
mv debian.deb $PKG_NAME.deb

cd $HOME_PATH
git checkout -- DEBIAN/postinst

