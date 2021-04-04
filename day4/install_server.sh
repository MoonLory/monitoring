#!/bin/bash

sudo yum install expect -y
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo setenforce 0 && sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

sudo dnf -y install @httpd
sudo systemctl enable --now httpd

sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
sudo dnf clean all
sudo dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent

sudo dnf -y install mariadb-server && sudo systemctl start mariadb && sudo systemctl enable mariadb

sudo ./inn_db.sh

sudo mysql -uroot -p'lory' -e "create database zabbix character set utf8 collate utf8_bin;"
sudo mysql -uroot -p'lory' -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbixDBpass';"

sudo mysql -uroot -p'lory' zabbix -e "set global innodb_strict_mode='OFF';"

sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p'zabbixDBpass' zabbix

sudo mysql -uroot -p'lory' zabbix -e "set global innodb_strict_mode='ON';"

sudo sh -c "echo 'DBPassword=zabbixDBpass'>> /etc/zabbix/zabbix_server.conf"

sudo systemctl restart zabbix-server 
sudo systemctl enable zabbix-server

sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
sudo firewall-cmd --reload

sudo sh -c "echo 'php_value[date.timezone] = Europe/Moscow' >> /etc/php-fpm.d/zabbix.conf"

sudo systemctl restart httpd php-fpm
sudo systemctl enable httpd php-fpm

sudo systemctl enable zabbix-agent.service
sudo systemctl restart zabbix-agent.service