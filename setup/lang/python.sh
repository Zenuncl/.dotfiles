#!/bin/bash


# Install python2 and python3
# Install pip2 and pip3
apt-get -y install \
  python \
  python3 \
  python-pip \
  python3-pip

# Install virtualenv
pip install virtualenv
pip3 install virtualenv
