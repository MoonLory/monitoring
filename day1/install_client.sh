#!/bin/bash

IP=${1}

sudo yum -y install openldap-clients nss-pam-ldapd
sudo authconfig --enableldap \
--enableldapauth \
--ldapserver=${IP} \
--ldapbasedn="dc=devopslab,dc=com" \
--enablemkhomedir \
--update
