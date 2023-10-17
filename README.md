# ec2-k8s-deploy

Building a Kubernetes cluster on AWS EC2

Create a `config.tfvars` and set the number of nodes, ami, volume, etc. there.

## Requirement

- [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) + ACCESS_KEY, SECRET_KEY
- pem file
  - private key for EC2 access
  - Convert from ppk to pem using tools like PuTTYgen

## tree

```sh
.
├── README.md
├── modules/               # Terraform Modules
│   ├── ec2/
│   │   └── multi_ubuntu/
│   └── sgroup/
│       └── allows_repos/   
├── init/
├── main.tf
├── params.tf
├── config.tfvars          # Don't Commit
└── config.tfvars.example  # Sample
```

## 커맨드

```sh
# 초기화: 필요한 provider 다운로드 및 새 module 인식
terraform init

# syntax, 인프라 구성 등에 문제없는지 apply 전 미리 확인가능
terraform plan -var-file="./config.tfvars"

# 인프라 구축
terraform apply -var-file="./config.tfvars" --auto-approve

# 인프라 종료
terraform destroy -var-file="./config.tfvars" --auto-approve

# 인프라 정보 출력
terraform show

# Output 정보 출력
terraform output
```

## Reference

- terraform 실행 후 생성된 tfstate파일을 삭제하면, terraform 클라이언트의 제어없이 인스턴스를 독립적으로 유지할 수 있다.
- RBN DNS 호스트 이름 IPv4 응답(Answer RBN DNS hostname IPv4) 옵션 활성화 방법
  - AWS 콘솔에서 인스턴스 실행시 Default로 활성화되어 있으나, `ec2-k8s-deploy`로 terraform 실행시 비활성화된 경우가 있다.
  - [문서](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-naming.html)를 참고하여 활성화 가능
  - 일반적으로 IP로 통신하므로 딱히 중요한 옵션은 아님
  - 극히 생소한 옵션이라 영어자료도 위 공식문서 밖에없음. GPT는 헛소리함.
