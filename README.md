# aws-kfk-test

aws-kfk-test

## 커맨드

- 해당경로에서,

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
