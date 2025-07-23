#!/bin/bash
set -e # 오류 발생 시 즉시 스크립트 종료

echo "=================================================="
echo "  Trip Agent 인프라 User Data 스크립트 시작  "
echo "=================================================="

# 1. 기본 환경 설정 및 필수 패키지 설치
echo "[INFO] 시스템 패키지 업데이트 중..."
sudo dnf update -y || { echo "[ERROR] 시스템 패키지 업데이트 실패. 종료."; exit 1; }

echo "[INFO] 필수 패키지 (git, docker, jq) 설치 중..."
# git: 코드 저장소 클론 등 향후 사용 가능성
# docker: 컨테이너 런타임
# jq: Secrets Manager 출력 파싱용 JSON 처리기
sudo dnf install -y git docker jq || { echo "[ERROR] 필수 패키지 설치 실패. 종료."; exit 1; }

# 2. Docker 서비스 설정 및 시작
echo "[INFO] Docker 서비스 시작 중..."
sudo systemctl start docker || { echo "[ERROR] Docker 서비스 시작 실패. 종료."; exit 1; }
sudo systemctl enable docker || { echo "[ERROR] Docker 서비스 활성화 실패. 종료."; exit 1; }

echo "[INFO] ec2-user를 docker 그룹에 추가 중..."
# ec2-user가 sudo 없이 docker 명령을 실행할 수 있도록 권한 부여 (재로그인 필요)
# 이 스크립트는 root 권한으로 실행되므로 sudo 사용
sudo usermod -aG docker ec2-user || { echo "[ERROR] ec2-user를 docker 그룹에 추가 실패. 종료."; exit 1; }

# 3. Docker Compose 플러그인 설치
echo "[INFO] Docker Compose 플러그인 설치 중..."
# Docker CLI 플러그인 디렉토리 생성
sudo mkdir -p /usr/local/lib/docker/cli-plugins/ || { echo "[ERROR] Docker CLI 플러그인 디렉토리 생성 실패. 종료."; exit 1; }
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose || { echo "[ERROR] Docker Compose 플러그인 다운로드 실패. 종료."; exit 1; }
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose || { echo "[ERROR] Docker Compose 플러그인 실행 권한 설정 실패. 종료."; exit 1; }
echo "[INFO] Docker Compose 플러그인 설치 완료."

# 4. ECR (Elastic Container Registry) 로그인 설정
echo "[INFO] IAM 인스턴스 프로파일 자격 증명으로 ECR 로그인 중..."
AWS_ACCOUNT_ID="${aws_account_id}" # Terraform template_file에서 주입
AWS_REGION="${aws_region}"         # Terraform template_file에서 주입
# Docker 클라이언트를 ECR에 인증
sudo docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com" <<< $(aws ecr get-login-password --region "${AWS_REGION}") || { echo "[ERROR] ECR 로그인 실패. IAM 권한 확인. 종료."; exit 1; }

echo "[INFO] ECR 로그인 성공."

# 5. docker-compose.yml 파일 생성
echo "[INFO] /home/ec2-user/에 docker-compose.yml 파일 생성 중..."
cat <<EOF > /home/ec2-user/docker-compose.yml
version: '3.8'
services:
  spring-app:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/spring-ecr:latest
    ports:
      - "8080:8080" # 호스트 8080 포트를 컨테이너 8080 포트에 매핑
    environment:
      # AWS Secrets Manager에서 DB 자격 증명 가져오기
      SPRING_DATASOURCE_USERNAME: "masteruser"
      SPRING_DATASOURCE_PASSWORD: "$(aws secretsmanager get-secret-value --secret-id /prod/db --query SecretString --output text | jq -r .password)"
      # Terraform에서 주입된 RDS 엔드포인트 및 포트
      SPRING_DATASOURCE_URL: "jdbc:postgresql://${db_instance_endpoint}:${db_instance_port}/teammjkdb"
    depends_on:
      - agent-app # spring-app이 agent-app 시작 후 시작되도록 의존성 설정

  agent-app:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/agent-ecr:latest
    ports:
      - "8000:8000" # 호스트 8000 포트를 컨테이너 8000 포트에 매핑
    environment:
      # AWS Secrets Manager에서 Gemini API 키 가져오기
      GEMINI_API_KEY: "$(aws secretsmanager get-secret-value --secret-id /prod/geminiApiKey --query SecretString --output text)"
EOF
echo "[INFO] docker-compose.yml 생성 완료."

# 6. Docker Compose를 사용하여 컨테이너 실행
echo "[INFO] Docker Compose 서비스 백그라운드 실행 중..."
# 플러그인 기반 설치를 위해 'docker compose' 명령 사용
sudo docker compose -f /home/ec2-user/docker-compose.yml up -d || { echo "[ERROR] Docker Compose 서비스 시작 실패. 종료."; exit 1; }

echo "=================================================="
echo "  User Data 스크립트 성공적으로 완료!         "
echo "=================================================="
