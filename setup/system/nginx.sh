#!/bin/bash

set -e

LNMP_VERSION=lnmp2.0

# Install LNMP
wget http://soft.vpser.net/lnmp/$LNMP_VErSION.tar.gz -cO lnmp.tar.gz && \
        tar zxf lnmp.tar.gz && \
        cd $LNMP_VERSION && \
        LNMP_Auto="y" DBSelect="0" PHPSelect="10" SelectMalloc="1" \
        ./install.sh lnmp

