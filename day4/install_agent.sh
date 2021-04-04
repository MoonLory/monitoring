#!/bin/bash

IP=${1}

sudo setenforce 0 && sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

sudo dnf -y install @httpd
sudo systemctl enable --now httpd

sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
sudo dnf clean all
sudo dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent

sudo sh -c "echo 'Server=$IP'>> /etc/zabbix/zabbix_agentd.conf"
sudo sh -c "echo 'Hostname=client1'>> /etc/zabbix/zabbix_agentd.conf"

sudo systemctl enable zabbix-agent
sudo systemctl restart zabbix-agent 

sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
sudo firewall-cmd --reload

sudo systemctl restart httpd php-fpm
sudo systemctl enable httpd php-fpm
