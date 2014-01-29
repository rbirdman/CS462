#!/bin/sh
#commands from http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingUserCerts.html

USER="ec2"

if [ $# -eq 0 ]
  then
  USER=$1
fi



openssl genrsa 1024 > $USER-private.pem
openssl req -new -x509 -nodes -sha1 -batch -days 365 -key $USER-private.pem -outform PEM > $USER.pem

#rm private-key.pem

echo Created certificate for:  $USER
