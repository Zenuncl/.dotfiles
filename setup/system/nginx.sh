#!/bin/bash

set -e


# Install LNMP
wget http://soft.vpser.net/lnmp/lnmp2.0.tar.gz -cO lnmp.tar.gz && \
        tar zxf lnmp.tar.gz && \
        cd lnmp && \
        LNMP_Auto="y" DBSelect="0" PHPSelect="10" SelectMalloc="1" \
        ./install.sh lnmp

