apt update
apt install curl sudo -y

# https://docs.gitea.com/runner/installation/binary/
VERSION=3.0.2   # any 3.x release, see the release page
curl -sSLO "https://dl.gitea.com/gitea-runner/$VERSION/gitea-runner-$VERSION-linux-amd64"
curl -sSLO "https://dl.gitea.com/gitea-runner/$VERSION/gitea-runner-$VERSION-linux-amd64.sha256"
sha256sum -c "gitea-runner-$VERSION-linux-amd64.sha256"
install -m 0755 "gitea-runner-$VERSION-linux-amd64" /usr/local/bin/gitea-runner
gitea-runner --version

# to run manually
# gitea-runner -c $CONFIG_PATH daemon

useradd --system --home-dir /var/lib/gitea-runner --create-home gitea-runner
install -d /etc/gitea-runner
sudo -u gitea-runner gitea-runner generate-config | sudo tee /etc/gitea-runner/config.yaml >/dev/null
cd /var/lib/gitea-runner
sudo -u gitea-runner gitea-runner register -c /etc/gitea-runner/config.yaml

cat << 'EOF' > /etc/systemd/system/gitea-runner.service
[Unit]
Description=Gitea Actions runner
Documentation=https://gitea.com/gitea/runner
After=network-online.target
Wants=network-online.target
# Uncomment when jobs use the local Docker daemon:
# After=docker.service
# Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/gitea-runner daemon --config /etc/gitea-runner/config.yaml
WorkingDirectory=/var/lib/gitea-runner
User=gitea-runner
Group=gitea-runner
Restart=on-failure
RestartSec=5s
# Allow running jobs to finish before the runner is stopped. Keep this in sync
# with runner.shutdown_timeout in the config.
TimeoutStopSec=3h
# Output to TTY1
StandardOutput=tty
StandardError=tty
TTYPath=/dev/tty1

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now gitea-runner
