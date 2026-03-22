# 🚀 Resilient AWS Infrastructure with Terraform & CI/CD



## 📌 Project Overview



This project demonstrates the design and deployment of a **resilient, scalable, and production-ready AWS infrastructure** using **Terraform (Infrastructure as Code)** and **GitHub Actions (CI/CD)**.



The architecture follows cloud best practices:

- High availability across multiple AZs

- Private/public subnet isolation

- Auto-scaling compute layer

- Managed database (RDS)

- Monitoring and alerting

- Secure remote state management

- CI/CD pipeline with approval workflow



---



## 🏗️ Architecture



### Key Components



- **VPC** with public & private subnets

- **Application Load Balancer (ALB)** (internet-facing)

- **Auto Scaling Group (ASG)** with EC2 instances (private subnets)

- **RDS PostgreSQL** (private, non-public)

- **NAT Gateway** for outbound internet access

- **Security Groups** (least privilege)

- **CloudWatch + SNS** for monitoring and alerts

- **CloudTrail** for auditing

- **SSM Session Manager** (no SSH access required)



---



## ⚙️ Infrastructure as Code (Terraform)



The infrastructure is fully defined using Terraform:



- Modular and readable `.tf` files

- Variables for configuration

- Outputs for key resources

- Remote state with:

&#x20; - **S3 bucket (versioned, encrypted)**

&#x20; - **DynamoDB (state locking)**



### Example files:

- `vpc.tf`

- `alb.tf`

- `autoscaling.tf`

- `rds.tf`

- `security.tf`

- `monitoring.tf`

- `cloudtrail.tf`



---



## 🔐 Remote State & Locking



Terraform state is stored securely:



- **S3 bucket**

&#x20; - Versioning enabled

&#x20; - Server-side encryption

&#x20; - No public access



- **DynamoDB**

&#x20; - Prevents concurrent Terraform executions

&#x20; - Ensures consistency



---



## 🔁 CI/CD Pipeline (GitHub Actions)



A complete CI/CD pipeline is implemented:



### 🔍 Continuous Integration



On each push:

- `terraform fmt`

- `terraform validate`

- `terraform plan`



### 🚀 Controlled Deployment



- Manual approval required before deployment

- Uses GitHub **Environments (production)**

- After approval → `terraform apply`



### 🔐 Secrets Management



Sensitive values are stored in GitHub Secrets:

- AWS credentials

- Database password

- Alert email



---



## 📊 Monitoring & Observability



- **CloudWatch metrics & alarms**

- **SNS notifications**

- **ALB health checks**

- Infrastructure visibility dashboard



---



## 🔒 Security Best Practices



- No SSH access → **SSM Session Manager**

- Private EC2 instances

- RDS not publicly accessible

- Strict Security Groups

- Encrypted state storage

- Secrets never stored in code



---



## 🧪 Example Output



After deployment:



- ALB DNS → public entry point

- Auto-scaled EC2 instances responding

- PostgreSQL database available internally



---



## 📸 Demo



Example response from the application:











## 🎯 What I Learned



- Designing resilient AWS architectures

- Writing production-ready Terraform code

- Managing Terraform state securely

- Implementing CI/CD pipelines for infrastructure

- Applying DevOps and cloud best practices



---



## 🚀 Future Improvements



- Multi-environment (dev/staging/prod)

- OIDC authentication (no static AWS keys)

- Terraform modules

- Blue/green deployment

- Cost optimization



---



## 👨‍💻 Author



Matteo – aspiring Cloud & DevOps Engineer



