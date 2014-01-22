#!/bin/bash
yum update -y
yum groupinstall -y "Web Server" "MySQL Database" "PHP Support"
yum install -y php-mysql
yum install -y httpd
service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
echo "<html>
<head>Ryan's Cool Title</head>
<body>
<h1>Ryan Bird</h1>
Behold my body :)
</body>
</html>" > /var/www/html/index.html

yum install git -y
cd ~/
git clone https://github.com/rbirdman/CS462.git
