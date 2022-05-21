# 사용 AMI
# Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
# ami-0454bb2fefc7de534 (64-bit x86)

export PROMETHEUS_PW=prom # prometheus 사용자 비밀번호

useradd -m -s /bin/bash prometheus
usermod -aG sudo prometheus				
echo prometheus:$PROMETHEUS_PW | chpasswd

# prometheus 사용자로 하위 명령어 실행
sudo -u prometheus /bin/bash -c "
cd ~ 
wget https://github.com/prometheus/prometheus/releases/download/v2.29.2/prometheus-2.29.2.linux-amd64.tar.gz
tar -xzvf prometheus-2.29.2.linux-amd64.tar.gz
mv prometheus-2.29.2.linux-amd64 prometheus

# systemctl 설정
echo $PROMETHEUS_PW | sudo -S bash -c 'cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=prometheus
Restart=on-failure

ExecStart=/home/prometheus/prometheus/prometheus   --config.file=/home/prometheus/prometheus/prometheus.yml   --storage.tsdb.path=/home/prometheus/prometheus/data

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo ss -nltp
"
