# K3s Agent (server url, token은 환경변수로 사전처리)
curl -sfL https://get.k3s.io | sh -s - --docker

# K3s kubeconfig 및 bashrc
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
echo 'alias k="kubectl"' >> ~/.bashrc
source ~/.bashrc


