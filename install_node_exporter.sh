#!/bin/bash

export VERSION=0.18.1
export ARCH=$(uname -m)

useradd -M -r -s /bin/false node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-$ARCH.tar.gz
tar xvfz node_exporter-$VERSION.linux-$ARCH.tar.gz

cp node_exporter-$VERSION.linux-$ARCH/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl start node_exporter

systemctl enable node_exporter

# curl localhost:9100/metrics

#  vi /etc/prometheus/prometheus.yml

# ...
# - job_name: 'Linux Server'
#  static_configs:
#  - targets: ['<PRIVATE_IP_ADDRESS_OF_NEW_SERVER>:9100']


#   killall -HUP prometheus