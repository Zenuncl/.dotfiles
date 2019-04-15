#!/bin/bash

# Install kubernetes
# Install dependency first
apt-get -y upadte && \
  apt-get -y install \
    apt-transport-https

# Add repo keys
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# setup repo
apt-add-repository \
  "deb https://apt.kubernetes.io/ \
  kubernetes-xenial \
  main"

# Install kubectl
apt-get update && \
  apt-get -y install \
  kubectl
