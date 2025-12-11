#!/bin/bash
yum update -y

# install web + php + mysql client
yum install -y httpd php php-mysqlnd php-fpm php-cli mariadb105-client wget

# start apache
systemctl enable httpd
systemctl start httpd

# download wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz -C /var/www/html --strip-components=1

# permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# restart apache
systemctl restart httpd
