#!/bin/bash

export VERSION=0.25.0
export ARCH=arm64

useradd -M -r -s /bin/false alertmanager

wget https://github.com/prometheus/alertmanager/releases/download/v$VERSION/alertmanager-$VERSION.linux-$ARCH.tar.gz
tar xvfz alertmanager-$VERSION.linux-$ARCH.tar.gz

cp alertmanager-$VERSION.linux-$ARCH/{alertmanager,amtool} /usr/local/bin/
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
mkdir -p /etc/alertmanager
cp alertmanager-$VERSION.linux-$ARCH/alertmanager.yml /etc/alertmanager
chown -R alertmanager:alertmanager /etc/alertmanager
mkdir -p /var/lib/alertmanager
chown alertmanager:alertmanager /var/lib/alertmanager
mkdir -p /etc/amtool

cat > /etc/amtool/config.yml <<EOF
alertmanager.url: http://localhost:9093
EOF

cat > /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
 --config.file /etc/alertmanager/alertmanager.yml \
 --storage.path /var/lib/alertmanager/

[Install]
WantedBy=multi-user.target
EOF

systemctl enable alertmanager
systemctl start alertmanager

# curl localhost:9093
# amtool config show

#  vi /etc/prometheus/prometheus.yml

# alerting:
#  alertmanagers:
#  - static_configs:
#  - targets: ["localhost:9093"]

#  systemctl restart prometheus

