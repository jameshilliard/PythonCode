#!/bin/bash
# install git
yum -y install git-client

# get automation project from git server
cd /root ;git clone git@192.168.10.241:~/automation;cd -

