#!/bin/bash

OWN_IP=${1}
SECRET=${2}

sudo yum install -y openldap openldap-servers openldap-clients
sudo systemctl start slapd
sudo systemctl enable slapd
sudo slappasswd -s ${SECRET} > hash
sudo sed -i "s%PASSWORD%$(cat hash)%" /home/centos/files/ldaprootpasswd.ldif /home/centos/files/ldapdomain.ldif /home/centos/files/ldapuser.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /home/centos/files/ldaprootpasswd.ldif
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/
sudo systemctl restart slapd
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /home/centos/files/ldapdomain.ldif
sudo ldapadd -w ${SECRET} -x -D cn=Manager,dc=devopslab,dc=com -f /home/centos/files/baseldapdomain.ldif
sudo ldapadd -w ${SECRET} -x -D "cn=Manager,dc=devopslab,dc=com" -f /home/centos/files/ldapgroup.ldif
sudo ldapadd -w ${SECRET} -x -D cn=Manager,dc=devopslab,dc=com -f /home/centos/files/ldapuser.ldif
#UI installation
sudo yum install -y epel-release
sudo yum install -y phpldapadmin
sudo sed -i "397s%// %%" /etc/phpldapadmin/config.php
sudo sed -i "398s%^%// %" /etc/phpldapadmin/config.php
sudo sed -i "11 aRequire ip ${OWN_IP}" /etc/httpd/conf.d/phpldapadmin.conf
sudo systemctl restart httpd
