#!/bin/bash
set -e

PROJECT_NAME="${project_name}"

# ── System update ──────────────────────────────────────
apt-get update -y
apt-get upgrade -y

# ── Install required packages ──────────────────────────
apt-get install -y nginx curl wget unzip awscli

# ── Nginx configuration ────────────────────────────────
systemctl enable nginx
systemctl start nginx

cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;
    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
NGINX

echo "<h1>$PROJECT_NAME is running!</h1><p>Deployed via Terraform + GitHub Actions</p>" > /var/www/html/index.html

nginx -t && systemctl reload nginx

# ── Node Exporter (Prometheus) ─────────────────────────
NODE_EXPORTER_VERSION="1.8.2"
wget -q https://github.com/prometheus/node_exporter/releases/download/v$${NODE_EXPORTER_VERSION}/node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
mv /tmp/node_exporter-$${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chmod +x /usr/local/bin/node_exporter

useradd -rs /bin/false node_exporter || true

cat > /etc/systemd/system/node_exporter.service << 'SERVICE'
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# ── CloudWatch Agent ───────────────────────────────────
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/cloudwatch-agent.deb
dpkg -i /tmp/cloudwatch-agent.deb || apt-get install -f -y

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CW'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/${project_name}",
            "log_stream_name": "nginx-access",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/${project_name}",
            "log_stream_name": "nginx-error",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": {
        "measurement": ["disk_used_percent"],
        "resources": ["/"]
      }
    }
  }
}
CW

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "Bootstrap complete for $PROJECT_NAME" >> /var/log/bootstrap.log
