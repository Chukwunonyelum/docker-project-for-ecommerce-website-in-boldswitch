
# docker-project-for-the-5th-assignment
### Updated README File with `.gitignore` Section

# **AWS Three-Tier Architecture Deployment**

This project demonstrates the creation and deployment of a three-tier architecture on AWS. The setup includes networking, compute resources, database configuration, containerized application deployment, and CI/CD integration using GitHub, Docker, and Amazon ECS.

---

## **Project Overview**

The three-tier architecture includes the following layers:
1. **Presentation Layer**: Frontend application served via an Application Load Balancer (ALB).
2. **Application Layer**: Backend application deployed on ECS containers.
3. **Data Layer**: MySQL RDS database securely deployed in private subnets.

---

## **Prerequisites**

Ensure you have the following tools installed and configured:
1. **AWS CLI** (Configured with proper IAM credentials).
2. **Git**.
3. **Docker**.
4. **Visual Studio Code**.
5. **Flyway** for database migrations.

---

## **Steps to Deploy the Architecture**

### **1. Networking Setup**
- **Create VPC**: Design the VPC with CIDR blocks.
- **Enable DNS Host Settings**.
- **Create Subnets**:
  - 2 public subnets in different Availability Zones (AZ1 and AZ2).
  - 4 private subnets in different Availability Zones.
- **Create Internet Gateway**: Attach it to the VPC.
- **Setup NAT Gateways**: One for each AZ for outgoing internet traffic from private subnets.
- **Create Route Tables**:
  - Public Route Table: Associate with public subnets and add routes for internet access.
  - Private Route Tables: One for each AZ, with routes to respective NAT gateways.
- **Edit Subnet Associations**: Link subnets to the appropriate route tables.

### **2. Security Groups**
- **Application Layer SG**:
  - Allows traffic on ports `80` and `443` from the ALB.
- **Database Layer SG**:
  - Allows MySQL/Aurora traffic on port `3306` from the application SG.

### **3. Data Layer Setup**
- **Create RDS Subnet Groups**: Use private subnets.
- **Launch RDS Instance**:
  - MySQL engine with appropriate instance class and storage.
  - Enable SSL for secure database connections.

### **4. Presentation Layer Setup**
- **Request SSL Certificate**: Use AWS Certificate Manager.
- **Create ALB**:
  - Configure listeners for HTTP and HTTPS.
  - Attach ALB to public subnets.
- **Route 53**:
  - Create a DNS record for the ALB.

### **5. Application Deployment**
#### **Prepare the Application Code**
- Create a **GitHub Repository** to store application and Dockerfile.
- Add public SSH key to GitHub for secure access.
- Clone the repository locally using PowerShell:
  ```bash
  git clone <repository-ssh-link>
  ```
- Push application code to GitHub.

#### **Containerize the Application**
- **Create a Dockerfile**:
  - Use multi-stage builds for efficiency.
  - Add build arguments and environment variables for secrets.
- **Create .gitignore**:
  - Exclude sensitive files like `.env` from version control.
  - Below is an example `.gitignore` file:
    ```gitignore
    # Ignore environment files
    *.nest-app.env



    # Docker files
    *.Dockerfile-reference
    


    # Build outputs
    *.build_image.ps1
    ```

- **Build and Test the Container**:
  ```bash
  docker build -t <image-name> .
  docker run -p 80:80 <image-name>
  ```
- **Push the Image**:
  - Create a Docker Hub repository.
  - Push the image to Docker Hub:
    ```bash
    docker push <docker-hub-repo-name>
    ```

#### **Push to Amazon ECR**
- Create an ECR repository in AWS.
- Push the container image to ECR:
  ```bash
  aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <ecr-repo-url>
  docker tag <image-name> <ecr-repo-url>:latest
  docker push <ecr-repo-url>:latest
  ```

---

### **6. ECS Configuration**
- **Create ECS Cluster**.
- **Task Definition**:
  - Define the container with resource limits and environment variables.
  - Add IAM roles for ECS tasks to access AWS services securely.
- **Service**:
  - Deploy tasks in the ECS cluster and associate them with the ALB.
- **Route 53 Record**:
  - Create a DNS record pointing to the ALB.

---

### **7. Monitoring and Logging**
- Enable **CloudWatch Logs** for ECS tasks and RDS.
- Use **ALB access logs** for traffic monitoring.
- Monitor system health with **CloudWatch Metrics** and custom dashboards.

---

### **8. Database Migrations**
- Download and install **Flyway**.
- Organize SQL scripts in the `sql` folder.
- Use an SSH tunnel to securely connect to the RDS instance.
- Run migrations:
  ```bash
  flyway -url=jdbc:mysql://<rds-endpoint>:3306/<db-name> -user=<db-user> -password=<db-password> migrate
  ```

---

## **Key Commands**

### **Clone Repository**
```bash
git clone <repository-ssh-link>
```

### **Build Docker Image**
```bash
docker build -t <image-name> .
```

### **Run Docker Container**
```bash
docker run -p 80:80 <image-name>
```

### **Push Docker Image to ECR**
```bash
docker tag <image-name> <ecr-repo-url>:latest
docker push <ecr-repo-url>:latest
```

---

## **Testing and Validation**
- **Web Application**:
  - Access the application via the ALB DNS name or Route 53 domain.
- **Database Connectivity**:
  - Ensure the application can read/write to the RDS database.
- **Monitoring**:
  - Validate logs and metrics in CloudWatch.

---

By including a properly configured `.gitignore` file, you protect sensitive environment files and ensure a clean and secure repository. Let me know if further details are needed!
