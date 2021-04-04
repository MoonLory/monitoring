#!/bin/bash

DD_AGENT_MAJOR_VERSION=7 DD_API_KEY="""""""""" DD_SITE="datadoghq.eu" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

sudo cat << EOF >> /etc/httpd/conf/httpd.conf
<Location /server-status>
    SetHandler server-status
    Order Deny,Allow
    Deny from all
    Allow from 127.0.0.1
</Location>
ExtendedStatus On
EOF
sudo systemctl restart httpd

sudo cat << EOF >> /etc/datadog-agent/conf.d/apache.d/conf.yaml.example
logs:
  - type: file
    path: /var/log/httpd/access_log
    source: apache
    sourcecategory: http_web_access
    service: apache
  - type: file
    path: /var/log/httpd/error_log
    source: apache
    sourcecategory: http_web_access
    service: apache
EOF

sudo chmod 655 -R /var/log/httpd
sudo service datadog-agent restart