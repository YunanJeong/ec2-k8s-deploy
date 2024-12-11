# 
# /etc/docker/daemon.json  # Registry and Logging settings  
# 
cat <<EOF > /tmp/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "insecure-registries": ["${URL_PRIVATE_DOCKER}", "${URL_DOCKER}"],
  "registry-mirrors": ["http://${URL_PRIVATE_DOCKER}","http://${URL_DOCKER}"]
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