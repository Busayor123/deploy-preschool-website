#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
cd /var/www/html 
wget https://github.com/Busayor123/Html-website/raw/main/xmen-main.zip
unzip xmen-main.zip 
cp -r techmax-main/* /var/www/html/ 
rm -rf xmen-main.zip 
systemctl enable httpd
systemctl start httpd