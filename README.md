# 🚀 Resilient Cloud-Native AWS Infrastructure (Terraform, ECS Fargate, WAF, CI/CD)

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

---

## 📖 Table of Contents

* [Project Overview](#-project-overview)
* [Architecture](#-Architecture)
    * [Key Components](#key-components)
* [Architecture Evolution](#-architecture-evolution)
    * [Auto Scaling & Stress Tests](#auto-scaling)
    * [Migration to ECS Fargate](#the-architecture-was-later-migrated-to-ecs-fargate)
* [Web Application Firewall (AWS WAF)](#-web-application-firewall-aws-waf)
    * [Implemented Rules](#implemented-rules)
    * [Attack Simulation Results](#results)
* [Infrastructure as Code (Terraform)](#-infrastructure-as-code-terraform)
* [Remote State & Locking](#-remote-state--locking)
* [CI/CD Pipeline (GitHub Actions)](#-cicd-pipeline-github-actions)
* [Monitoring & Observability](#-monitoring--observability)
* [Security Best Practices](#-security-best-practices)
* [HTTPS (Not Implemented)](#-https-not-implemented)
* [What I Learned](#-what-i-learned)
* [Author](#-author)

---

## 📌 Project Overview

This project demonstrates the design and deployment of a **resilient, scalable, and cloud-native AWS infrastructure** using **Terraform (Infrastructure as Code)** and **GitHub Actions (CI/CD)**.

The architecture follows modern cloud best practices:

- High availability across multiple AZs  
- Private/public subnet isolation  
- Containerized application (Docker)  
- Deployment using **ECS Fargate**  
- Image storage with **Amazon ECR**  
- Layer 7 protection using **AWS WAF**  
- Managed database (RDS)  
- Monitoring, alerting and auditing  

The project evolved from an EC2-based architecture to a **fully containerized deployment**, improving scalability and reducing operational overhead.



##  Architecture



### Key Components

- **VPC** with public & private subnets across 2 AZs  
- **Application Load Balancer (ALB)** (internet-facing)  
- **ECS Fargate** (containerized application in private subnets)  
- **Amazon ECR** (Docker image registry)  
- **RDS PostgreSQL** (private, single AZ)  
- **NAT Gateway** for outbound internet access  
- **Security Groups** (least privilege access)  
- **CloudWatch + SNS** for monitoring and alerting  
- **CloudTrail** for auditing  
- **AWS WAF** for Layer 7 protection  
- **SSM Session Manager** (no SSH access required)



---

## 🔄 Architecture Evolution

The initial version of the infrastructure was based on EC2 instances managed by an Auto Scaling Group.

- EC2 instances deployed in private subnets  
- Auto Scaling Group based on CPU utilization  
- ALB distributing traffic to EC2 instances


![AWS Architecture](images/architecture.png)

### Auto scaling

Initially, the infrastructure runs with two instances.

![Instances default number](images/2_Instances.png)

To simulate high traffic and CPU consumption, we used the command `stress --cpu 2 --timeout 600`.

This command launches two CPU worker threads (`--cpu 2`) in order to generate processor load for 600 seconds (`--timeout 600`), which corresponds to 10 minutes.

![Command Stress](images/stress_command.png)


At the same time, CPU utilization can be monitored in real time through Amazon CloudWatch.

Once CPU utilization exceeds the configured threshold of 50%, the auto scaling policy is triggered and new instances begin to launch automatically.

![Command Stress](images/Alarmes_CPU.png)

![Build third instances](images/creation_3eme_instance.png)

![third instances](images/3eme_instance.png)

The service indicates that the scaling operation succeeded and increases the number of running instances from 2 to 4 in order to handle the additional load.

![notif auto scaling starting](images/notification_auto_scaling.png)


## The architecture was later **migrated to ECS Fargate**:

- Containerized application (Docker)  
- Deployment via ECS Service  
- No server management required

![Docker](images/Docker_architecture.png)

![Docker](images/creation_containers.png)

![Docker](images/creation_containers_completed.png)

👉 This transition improved scalability, flexibility, and reduced operational overhead.




## 🔐 Web Application Firewall (AWS WAF)

An AWS WAF Web ACL is deployed and attached to the Application Load Balancer to protect the application from Layer 7 attacks.

### Implemented Rules

- **AWSManagedRulesCommonRuleSet**  
  → Protects against common web attacks (SQL injection, XSS, malformed requests)

- **AWSManagedRulesKnownBadInputsRuleSet**  
  → Detects and blocks known malicious payload patterns

- **Rate-based rule**  
  → Limits requests per IP (100 requests / 5 minutes) to mitigate abusive traffic

### Results

- I simulated application attacks (SQL injection, XSS)
- and High-frequency request bursts

###  High-frequency request bursts command (PowerShell) : 

It triggers 500 asynchronous web requests toward the Application Load Balancer (ALB).

```powershell
for ($i = 0; $i -lt 500; $i++) {
    Start-Job {
        Invoke-WebRequest -Uri "[http://resilient-aws-infra-alb-828325941.eu-west-3.elb.amazonaws.com](http://resilient-aws-infra-alb-828325941.eu-west-3.elb.amazonaws.com)" -UseBasicParsing | Out-Null
    }
}
```
- Abnormal traffic patterns were detected  

![result_known_badinputs](images/Known_bad_inputs.png)

- Protection effectiveness confirmed via AWS WAF metrics

![result_rate_limit](images/rule_limit.png)

###  XSS attacks :   
![command commun_rules](images/XSS_attack.png)

Malicious requests were successfully blocked : 

![result_commun_rules](images/Commun-rules.png)





##  Infrastructure as Code (Terraform)



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



##  Remote State & Locking



Terraform state is stored securely:



- **S3 bucket**

&#x20; - Versioning enabled

&#x20; - Server-side encryption

&#x20; - No public access



- **DynamoDB**

&#x20; - Prevents concurrent Terraform executions

&#x20; - Ensures consistency



---



##  CI/CD Pipeline (GitHub Actions)



A complete CI/CD pipeline is implemented:



###  Continuous Integration



On each push:

- `terraform fmt`

- `terraform validate`

- `terraform plan`



###  Controlled Deployment



- Manual approval required before deployment

- Uses GitHub **Environments (production)**

- After approval → `terraform apply`



###  Secrets Management



Sensitive values are stored in GitHub Secrets:

- AWS credentials

- Database password

- Alert email



---



##  Monitoring & Observability



- **CloudWatch metrics & alarms**

- **SNS notifications**

- **ALB health checks**

- Infrastructure visibility dashboard



---



##  Security Best Practices



- No SSH access → **SSM Session Manager**

- Private EC2 instances

- RDS not publicly accessible

- Strict Security Groups

- Encrypted state storage

- Secrets never stored in code



---






---


---






---

## 🔐 HTTPS (Not Implemented)

HTTPS is not implemented in this project.

### Reason

This infrastructure is designed as a **demonstration environment** and is not intended to be maintained long-term.

### Planned improvement

- TLS via AWS Certificate Manager (ACM)
- HTTPS listener on ALB
- HTTP → HTTPS redirection



##  What I Learned



- Designing resilient AWS architectures

- Writing production-ready Terraform code

- Managing Terraform state securely

- Implementing CI/CD pipelines for infrastructure

- Applying DevOps and cloud best practices



---







##  Author



Matteo –  Cloud & DevOps junior Engineer 



