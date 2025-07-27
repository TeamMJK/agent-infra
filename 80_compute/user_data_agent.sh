#!/bin/bash
set -e # 명령 실패 시 스크립트 즉시 종료

echo "=================================================="
echo "  Trip Agent 인프라 User Data 스크립트 시작 (Agent)  "
echo "=================================================="

# 1. 기본 환경 설정 및 필수 패키지 설치
echo "[INFO] 시스템 패키지 업데이트 중..."
sudo dnf update -y || { echo "[ERROR] 시스템 패키지 업데이트 실패. 종료."; exit 1; }

echo "[INFO] 필수 패키지 (git, docker, jq) 설치 중..."
sudo dnf install -y git docker jq || { echo "[ERROR] 필수 패키지 설치 실패. 종료."; exit 1; }

# 2. Docker 서비스 설정 및 시작
echo "[INFO] Docker 서비스 시작 중..."
sudo systemctl start docker || { echo "[ERROR] Docker 서비스 시작 실패. 종료."; exit 1; }
sudo systemctl enable docker || { echo "[ERROR] Docker 서비스 활성화 실패. 종료."; exit 1; }

echo "[INFO] ec2-user를 docker 그룹에 추가 중..."
sudo usermod -aG docker ec2-user || { echo "[ERROR] ec2-user를 docker 그룹에 추가 실패. 종료."; exit 1; }

# 3. ECR (Elastic Container Registry) 로그인 설정
echo "[INFO] IAM 인스턴스 프로파일 자격 증명으로 ECR 로그인 중..."
aws ecr get-login-password --region "${aws_region}" | sudo docker login --username AWS --password-stdin "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com" || { echo "[ERROR] ECR 로그인 실패. IAM 권한 확인. 종료."; exit 1; }
echo "[INFO] ECR 로그인 성공."

# 4. Agent App 컨테이너 실행
echo "[INFO] Agent App 컨테이너 실행 시작..."
# AWS Secrets Manager에서 Gemini API 키 가져오기
GEMINI_API_KEY=$(aws secretsmanager get-secret-value --secret-id /teammjk/geminiApiKey --query SecretString --output text) || { echo "[ERROR] Gemini API 키 가져오기 실패. 종료."; exit 1; }

sudo docker run -d \
  --name agent-app \
  -p 8000:8000 \
  --restart always \
  -e GEMINI_API_KEY="${GEMINI_API_KEY}" \
  "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/agent-ecr:latest" || { echo "[ERROR] Agent App 컨테이너 실행 실패. 종료."; exit 1; }

echo "[INFO] Agent App 컨테이너 시작됨."

echo "=================================================="
echo "  Agent User Data 스크립트 성공적으로 완료!         "
echo "=================================================="