#!/bin/bash

sudo yum update
sudo amazon-linux-extras install nginx1
sudo systemctl start nginx
sudo systemctl enable nginx
sudo mkfs -t xfs /dev/xvdb
sudo mount /dev/xvdb /var/log