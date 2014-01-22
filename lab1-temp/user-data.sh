#!/bin/bash
yum update -y

yum install git -y
cd ~/
git clone https://github.com/rbirdman/CS462.git

yum -y install gcc mysql-devel ruby-devel rubygems
yum install gem -y
gem update

gem install rails


