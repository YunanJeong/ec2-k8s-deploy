# K3s Agent (server url, token은 환경변수로 사전처리)
export K3S_URL=${K3S_URL:?"https://myK3sApiServerIp:6443 형식으로 할당"}
export K3S_TOKEN=${K3S_TOKEN:?"k3s-server에서 /var/lib/rancher/k3s/server/node-token 값을 가져와 할당"}
curl -sfL https://get.k3s.io | sh -s - --docker

# K3s kubeconfig 및 bashrc
# echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
# echo 'alias k="kubectl"' >> ~/.bashrc
# source ~/.bashrc
