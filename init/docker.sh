# 
# /etc/docker/daemon.json  # Registry and Logging settings  
# 
# 로그 설정 없을시 disk full
# k3s와 함께 사용시 로그max-size는 반드시 10m 고정(로그파일로테이션 오류확률 감소)
URL_DOCKER=${URL_DOCKER:-"docker.wai"}  # If not set, default used
cat <<EOF > /tmp/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "100"
  },
  "insecure-registries": ["${URL_DOCKER}"],
  "registry-mirrors": ["http://${URL_DOCKER}"]
}
EOF

sudo mkdir -p /etc/docker
sudo mv /tmp/daemon.json /etc/docker/daemon.json

#
# Install
#
# https://docs.docker.com/engine/install/ubuntu/
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Non-root settings
# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
# sudo groupadd docker
sudo usermod -aG docker $USER
# newgrp docker