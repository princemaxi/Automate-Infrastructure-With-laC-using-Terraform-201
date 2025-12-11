#!/bin/bash
yum update -y
yum install httpd php -y
systemctl enable httpd
systemctl start httpd
echo "Tooling Website" > /var/www/html/index.html
