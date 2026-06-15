#!/bin/bash
# ─────────────────────────────────────────────
# install-node-exporter.sh
# Installs Prometheus Node Exporter as a systemd service
# ─────────────────────────────────────────────
set -euo pipefail

NODE_EXPORTER_VERSION="${1:-1.8.2}"
ARCH="amd64"
BINARY_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH}.tar.gz"

echo "[$(date)] Installing Node Exporter v$NODE_EXPORTER_VERSION..."

# Download and install
wget -q "$BINARY_URL" -O /tmp/node_exporter.tar.gz
tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
mv /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH}/node_exporter /usr/local/bin/
chmod +x /usr/local/bin/node_exporter
rm -rf /tmp/node_exporter*

# Create system user
useradd -rs /bin/false node_exporter 2>/dev/null || true

# Create systemd service
cat > /etc/systemd/system/node_exporter.service << 'SERVICE'
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
After=network-online.target
Wants=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --collector.systemd \
    --collector.processes
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "[$(date)] Node Exporter installed and running on :9100"
node_exporter --version
