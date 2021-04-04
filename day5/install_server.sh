#!/bin/bash

cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
sudo tar -xzf prometheus-2.26.0.linux-amd64.tar.gz
sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chmod 755 prometheus-2.26.0.linux-amd64 -R
sudo chown prometheus:prometheus prometheus-2.26.0.linux-amd64 -R
sudo cp /tmp/config/prometheus.service /etc/systemd/system/prometheus.service

wget https://github.com/prometheus/node_exporter/releases/download/v0.16.0/node_exporter-0.16.0.linux-amd64.tar.gz
tar xvf node_exporter-0.16.0.linux-amd64.tar.gz
sudo cp node_exporter-0.16.0.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.16.0.linux-amd64.tar.gz node_exporter-0.16.0.linux-amd64
sudo cp /tmp/config/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl start node_exporter

sudo systemctl daemon-reload
sudo systemctl start prometheus.service
sudo systemctl enable prometheus.service

sudo cp /tmp/config/grafana.repo /etc/yum.repos.d/grafana.repo
sudo yum install grafana -y
sudo systemctl start grafana-server

cd /opt
sudo wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.18.0/blackbox_exporter-0.18.0.linux-amd64.tar.gz
sudo tar -xzf blackbox_exporter-0.18.0.linux-amd64.tar.gz
sudo chown -R prometheus:prometheus blackbox_exporter-0.18.0.linux-amd64.tar.gz
sudo cp /tmp/config/blackbox.service /etc/systemd/system/blackbox.service
sudo systemctl daemon-reload
sudo systemctl start blackbox.service

sudo cat << EOF >> /opt/prometheus-2.26.0.linux-amd64/prometheus.yml
  - job_name: 'blackbox'
    static_configs:
    - targets: ['localhost:9115'] # The blackbox exporter's real hostname:port.
EOF

sudo systemctl restart prometheus.service