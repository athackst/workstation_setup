#!/bin/bash
# https://blog.packagecloud.io/how-to-build-debian-packages-for-simple-shell-scripts/
VERSION=0.1
PKG_NAME=althack-workstation-setup-$VERSION

mkdir $PKG_NAME

cp -r user $PKG_NAME
cp -r scripts $PKG_NAME
cp -r programs $PKG_NAME
cp LICENSE $PKG_NAME
cp -r debian $PKG_NAME

cd $PKG_NAME

dh_make --indep --createorig -y

debuild -us -uc
