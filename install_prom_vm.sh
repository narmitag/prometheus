#!/bin/bash


export VERSION=2.16.0
export ARCH=arm64

useradd -M -r -s /bin/false prometheus
mkdir /etc/prometheus /var/lib/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v$VERSION/prometheus-$VERSION.linux-$ARCH.tar.gz
tar xzf prometheus-$VERSION.linux-$ARCH.tar.gz prometheus-$VERSION.linux-$ARCH/

cp prometheus-$VERSION.linux-$ARCH/{prometheus,promtool} /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

cp -r prometheus-$VERSION.linux-$ARCH/{consoles,console_libraries} /etc/prometheus/
cp prometheus-$VERSION.linux-$ARCH/prometheus.yml /etc/prometheus/prometheus.yml

chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus


cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Time Series Collection and Processing Server
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
 --config.file /etc/prometheus/prometheus.yml \
 --storage.tsdb.path /var/lib/prometheus/ \
 --web.console.templates=/etc/prometheus/consoles \
 --web.console.libraries=/etc/prometheus/console_libraries
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus


#Check with curl localhost:9090
#and
#http://<ServerIP>:9090