<img width="962" height="991" alt="image" src="https://github.com/user-attachments/assets/bd6db108-9c8e-4658-aec0-d04016528549" />

<br>

## 아키텍쳐 수정 2025.07.12
Free-Tier 기간내에 활용할 수 있는 리소스들을 적극 도입하여 비용 최적화

## Multi-AZ Subnets-Provision-Only 
실제 리소스는 단일 AZ, 향후 다중 AZ 배포를 위한 서브넷 준비작업만 수행


## Fix
| **항목** | **기존 설계** | **수정 후 (Free-Tier 활용)** |
| --- | --- | --- |
| **Compute** | ECS Fargate 멀티컨테이너 | **EC2 t3.micro 1대** (도커 런타임) – Spring Boot + FastAPI 컨테이너를 docker-compose로 실행 – 퍼블릭 서브넷에 배치, SSH·Docker 권한 |
| **DB** | Aurora Serverless v2 | **RDS PostgreSQL db.t3.micro (Free Tier)** – 프라이빗 서브넷, 단일-AZ |
| **인프라 접근 권한** | 한 계정, 콘솔 전부 사용 | **단일 AWS 계정 + IAM 사용자**  • **infra-admin** (이재영): AdministratorAccess  • **dev-backend** (최명재, 신예준)|
| **ALB** | 유지 (TLS 종단, WAF) | **유지** – EC2 Target Group으로 변경 |
| **CloudFront + S3** | 그대로 유지 | 변경 없음 |
| **WAF** | 유지 | 변경 없음 |
