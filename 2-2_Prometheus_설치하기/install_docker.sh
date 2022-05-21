# 사용 AMI
# Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
# ami-0454bb2fefc7de534 (64-bit x86)

export PROMETHEUS_PW=prom # prometheus 사용자 비밀번호
export PROMETHEUS_CONFIG="/home/prometheus/config" # prometheus 설정 디렉토리 경로
export PROMETHEUS_DATA="/home/prometheus/data" # prometheus 데이터 저장 경로

apt install -y docker.io
useradd -m -s /bin/bash prometheus
usermod -aG sudo prometheus
usermod -aG docker prometheus
echo prometheus:$PROMETHEUS_PW | chpasswd

# prometheus 사용자로 하위 명령어 실행
sudo -u prometheus /bin/bash -c "
cd ~

mkdir -p $PROMETHEUS_CONFIG
mkdir -p $PROMETHEUS_DATA
echo $PROMETHEUS_PW | sudo -S chown -R 65534:65534 /home/prometheus/data

# prometheus 설정 파일 생성
cat << EOF > $PROMETHEUS_CONFIG/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF

# docker를 통한 prometheus 컨테이너 실행
docker run \
-d \
--name=prometheus \
--network=host \
-v $PROMETHEUS_CONFIG:/etc/prometheus  \
-v $PROMETHEUS_DATA:/data \
prom/prometheus:v2.29.2 \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/data --web.enable-lifecycle \
--storage.tsdb.retention.time=10d
"
