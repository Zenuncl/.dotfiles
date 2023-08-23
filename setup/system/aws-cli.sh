#!/bin/zsh


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

unzip /tmp/awscliv2.zip  -d /tmp

/tmp/aws/install --bin-dir /home/sharking/.local/bin --install-dir /home/sharking/.local/aws-cli --update

