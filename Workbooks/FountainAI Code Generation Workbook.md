# **FountainAI Code Generation Workbook**

This workbook provides a comprehensive guide to generating, modifying, deploying, and managing FountainAI services using OpenAI's GPT-4 model via the OpenAI API. It focuses on creating scripted interactions with the model to generate code based on versioned OpenAPI specifications. Additionally, it utilizes shell scripts to automate code modifications, deployments, and teardowns, following the **FountainAI shell scripting guidelines**. Essential security practices, such as implementing HTTPS using AWS Certificate Manager (ACM), are included to ensure secure communication at all development stages.

---

## **Table of Contents**

1. [Introduction](#1-introduction)
2. [Prerequisites](#2-prerequisites)
3. [Project Setup](#3-project-setup)
4. [Defining Versioned OpenAPI Specifications](#4-defining-versioned-openapi-specifications)
5. [Code Generation with GPT-4 via OpenAI API](#5-code-generation-with-gpt-4-via-openai-api)
   - [5.1 Setting Up the OpenAI API Client](#51-setting-up-the-openai-api-client)
   - [5.2 Generating Code for Central Sequence Service](#52-generating-code-for-central-sequence-service)
6. [Shell Scripting in FountainAI](#6-shell-scripting-in-fountainai)
   - [6.1 Introduction to FountainAI Shell Scripting](#61-introduction-to-fountainai-shell-scripting)
   - [6.2 Idempotency and Script Structure](#62-idempotency-and-script-structure)
   - [6.3 Shell Script Style Guide](#63-shell-script-style-guide)
7. [Modifying Code with Shell Scripts](#7-modifying-code-with-shell-scripts)
8. [Initializing GitHub Repositories](#8-initializing-github-repositories)
9. [Deploying Services to AWS](#9-deploying-services-to-aws)
10. [Managing DNS Settings with AWS CLI and Route53](#10-managing-dns-settings-with-aws-cli-and-route53)
11. [Implementing HTTPS with AWS Certificate Manager (ACM)](#11-implementing-https-with-aws-certificate-manager-acm)
    - [11.1 Requesting an SSL/TLS Certificate](#111-requesting-an-ssltls-certificate)
    - [11.2 Updating the CloudFormation Template](#112-updating-the-cloudformation-template)
    - [11.3 Updating the Deployment Script](#113-updating-the-deployment-script)
12. [Tearing Down AWS Deployments Using CloudFormation](#12-tearing-down-aws-deployments-using-cloudformation)
13. [Testing the Application](#13-testing-the-application)
14. [Reference Table](#14-reference-table)
15. [Conclusion](#15-conclusion)
16. [Next Steps](#16-next-steps)
17. [Appendix A: AWS Cost Estimation](#17-appendix-a-aws-cost-estimation)
    - [17.1 Importance of Cost Estimation](#171-importance-of-cost-estimation)
    - [17.2 AWS Cost Estimation Script](#172-aws-cost-estimation-script)

---

## **1. Introduction**

This workbook demonstrates how to generate fully-fledged, deployable, and testable FastAPI applications for FountainAI services by interacting with GPT-4 via the OpenAI API. By following the steps outlined, you will:

- Generate code for services using GPT-4 with scripted API calls.
- Modify the code using shell scripts that adhere to FountainAI norms.
- Initialize GitHub repositories using the GitHub CLI (`gh`).
- Deploy services to AWS using AWS CLI and CloudFormation, following FountainAI guidelines.
- Manage DNS settings using AWS CLI for Route53 to configure the domain **fountain.coach**.
- **Implement HTTPS** by securing your service with SSL/TLS certificates using AWS Certificate Manager (ACM).
- **Estimate AWS costs** using a cost calculation script to understand the financial implications.
- Tear down AWS deployments using CloudFormation templates and scripts.

We will be using the actual OpenAPI specification of the Central Sequence Service from the FountainAI repository: [Contexter/FountainAI](https://github.com/Contexter/FountainAI).

---

## **2. Prerequisites**

Ensure you have the following:

- **OpenAI API Access**: An API key with access to GPT-4.
- **GitHub CLI (`gh`)**: Installed and authenticated. [GitHub CLI Documentation](https://cli.github.com/manual/)
- **AWS CLI (`aws`)**: Installed and configured with appropriate permissions. [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- **Python 3.7+**: Installed.
- **Docker and Docker Compose**: Installed. [Docker Installation Guide](https://docs.docker.com/get-docker/)
- **FountainAI Guide**: Familiarity with FountainAI norms and shell scripting guidelines.
- **Domain Ownership**: You own the domain **fountain.coach** and have access to its DNS settings.
- **AWS CloudFormation**: Familiarity with AWS CloudFormation templates and stack management. [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/index.html)
- **AWS Certificate Manager (ACM)**: Permissions to request and manage SSL/TLS certificates. [AWS Certificate Manager Documentation](https://docs.aws.amazon.com/acm/latest/userguide/)
- **AWS Pricing Calculator**: Access to the AWS Pricing Calculator for estimating costs. [AWS Pricing Calculator](https://calculator.aws/)

Set your OpenAI API key as an environment variable:

```bash
export OPENAI_API_KEY='your-openai-api-key'
```

---

## **3. Project Setup**

Create a project directory and set up a virtual environment:

```bash
mkdir fountainai
cd fountainai
python3 -m venv venv
source venv/bin/activate
```

Install required Python packages:

```bash
pip install openai pyyaml
```

---

## **4. Defining Versioned OpenAPI Specifications**

Use the actual OpenAPI specification of the Central Sequence Service from the FountainAI repository, located at `openAPI/central-sequence-service.yaml`.

Create a directory for OpenAPI specs:

```bash
mkdir openapi_specs
```

Create `openapi_specs/central_sequence_service.yaml` and paste the following content:

```yaml
# [OpenAPI specification content as provided earlier]
```

---

## **5. Code Generation with GPT-4 via OpenAI API**

### **5.1 Setting Up the OpenAI API Client**

Create a Python script `generate_code.py` to interact with the OpenAI API and generate code based on the OpenAPI specification.

Install the OpenAI Python library:

```bash
pip install openai
```

### **5.2 Generating Code for Central Sequence Service**

Create `generate_code.py`:

```python
# [generate_code.py content as provided earlier]
```

**Run the script:**

```bash
python generate_code.py
```

**Notes:**

- The script reads the OpenAPI specification and constructs a prompt.
- It sends the prompt to the GPT-4 model via the OpenAI API.
- It parses the response and saves the code files in the `services/central_sequence_service` directory.

---

## **6. Shell Scripting in FountainAI**

### **6.1 Introduction to FountainAI Shell Scripting**

Shell scripting has long been a cornerstone of system automation. In FountainAI, the deterministic nature of shell scripts is leveraged to automate and deploy infrastructure consistently. These scripts execute precise, repeatable actions, ensuring the system behaves identically on each run. From placing OpenAPI specifications in the correct locations to generating GitHub Actions workflows, every step is clearly defined, leaving no room for ambiguity.

### **6.2 Idempotency and Script Structure**

**Idempotency** is a key principle that underpins the reliability of the scripts used in FountainAI's deployment. In shell scripting, idempotency means that running a script multiple times results in the same outcome, without unintended side effects.

For example:

- If a directory already exists, the script won't attempt to recreate it.
- If a service is already running, it won't attempt to restart it unless specified.

By ensuring all shell scripts in FountainAI are idempotent, a foundation for reliable, automated deployment is provided.

### **6.3 Shell Script Style Guide**

In FountainAI, the style guide for shell scripts ensures that every script is modular, understandable, and idempotent.

**1. Modular Functions**

Each shell script is divided into small, reusable functions that are easy to call and maintain. Every function has a clear purpose, reducing redundancy and making scripts more adaptable.

**Example:**

```bash
# [Example content as provided earlier]
```

**2. Idempotency**

Ensuring that running a script multiple times results in the same outcome.

**Example:**

```bash
# [Example content as provided earlier]
```

**3. Commenting and Structure**

Scripts should be fully commented, with clear explanations of what each function does and the expected outcome.

**Example:**

```bash
# [Example content as provided earlier]
```

**4. Using Shell Scripts as Orchestrators and Code Writers**

Shell scripts in FountainAI have two primary roles:

- **Command Invocation**: Issuing commands that invoke external tools and services.
- **Code Generation (Code Writing)**: Generating code and configuration files deterministically.

**Example of Code Generation:**

```bash
# [Example content as provided earlier]
```

---

## **7. Modifying Code with Shell Scripts**

Create a script `modify_code.sh` to modify the generated code according to FountainAI norms.

**Create `modify_code.sh`:**

```bash
# [modify_code.sh content as provided earlier]
```

**Make the script executable:**

```bash
chmod +x modify_code.sh
```

**Run the script:**

```bash
./modify_code.sh
```

**Notes:**

- The script is modular, with each function performing a specific task.
- Idempotency is ensured; running the script multiple times won't cause issues.
- The script is fully commented and adheres to the FountainAI shell scripting style guide.

---

## **8. Initializing GitHub Repositories**

Initialize a GitHub repository for the service using the GitHub CLI (`gh`).

**Create `init_repo.sh`:**

```bash
# [init_repo.sh content as provided earlier]
```

**Make the script executable:**

```bash
chmod +x init_repo.sh
```

**Run the script:**

```bash
./init_repo.sh
```

**Notes:**

- The script uses modular functions.
- Idempotency is ensured by checking if the Git repository already exists.
- Comments explain each function and its purpose.

---

## **9. Deploying Services to AWS**

Deploy the service to AWS using AWS CLI and CloudFormation, following FountainAI norms.

**Create `deploy_to_aws.sh`:**

```bash
# [deploy_to_aws.sh content as provided earlier]
```

**Make the script executable:**

```bash
chmod +x deploy_to_aws.sh
```

**Run the script:**

```bash
./deploy_to_aws.sh
```

**Notes:**

- The script uses AWS CloudFormation for deploying resources, including an Application Load Balancer configured for HTTPS.
- Replace placeholders like `your-database-url`, `your-vpc-id`, `your-subnet-ids`, and `your-security-group-id` in the CloudFormation template and deployment script.
- Ensure the IAM role `ecsTaskExecutionRole` exists or update the template accordingly.
- The script is modular and idempotent.
- **References:**
  - [AWS ECR Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html)
  - [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
  - [AWS CloudFormation Deploy Command](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy/index.html)
  - [AWS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
  - [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

---

## **10. Managing DNS Settings with AWS CLI and Route53**

Configure DNS settings in AWS Route53 using AWS CLI to map the domain **fountain.coach** to your service.

**Create `update_dns.sh`:**

```bash
# [update_dns.sh content as provided earlier]
```

**Make the script executable:**

```bash
chmod +x update_dns.sh
```

**Run the script:**

```bash
./update_dns.sh
```

**Notes:**

- Replace `YOUR_HOSTED_ZONE_ID` with your actual hosted zone ID.
- The script retrieves the Load Balancer DNS from CloudFormation stack outputs.
- The script is modular and idempotent.
- **References:**
  - [AWS Route53 Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)
  - [AWS CLI Route53 Commands](https://docs.aws.amazon.com/cli/latest/reference/route53/index.html)

---

## **11. Implementing HTTPS with AWS Certificate Manager (ACM)**

Securing your service with HTTPS is essential to protect data in transit and prevent unauthorized access. This section guides you through requesting an SSL/TLS certificate using AWS Certificate Manager (ACM) and updating your deployment to use HTTPS.

### **11.1 Requesting an SSL/TLS Certificate**

**Create `request_certificate.sh`:**

```bash
# [request_certificate.sh content as provided earlier]
```

**Make the script executable:**

```bash
chmod +x request_certificate.sh
```

**Install `jq` utility if not already installed:**

```bash
sudo apt-get install jq
```

**Run the script:**

```bash
./request_certificate.sh
```

**Notes:**

- Replace `YOUR_HOSTED_ZONE_ID` with your actual Route53 Hosted Zone ID.
- The script requests a certificate, retrieves the DNS validation record, and adds it to Route53.
- It waits for the certificate to be validated before proceeding.
- **References:**
  - [AWS Certificate Manager User Guide](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
  - [Request a Public Certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)
  - [AWS CLI ACM Commands](https://docs.aws.amazon.com/cli/latest/reference/acm/index.html)

### **11.2 Updating the CloudFormation Template**

Modify your `deploy_to_aws.sh` script to include the SSL certificate and update the load balancer to use HTTPS.

Update the `create_cloudformation_template` function in `deploy_to_aws.sh` as shown in the previous section.

### **11.3 Updating the Deployment Script**

Update the `deploy_cloudformation_stack` function in `deploy_to_aws.sh` to pass in the required parameters.

**Run the updated deployment script:**

```bash
./deploy_to_aws.sh
```

**Important:**

- Ensure that you have the necessary permissions to create and manage the resources.
- The stack will now include an ALB configured to handle HTTPS traffic.
- **References:**
  - [Application Load Balancer Listeners](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
  - [Using HTTPS with Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
  - [AWS CloudFormation Template Anatomy](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html)

---

## **12. Tearing Down AWS Deployments Using CloudFormation**

Create tear-down scripts to safely remove AWS deployments using CloudFormation.

**Create `teardown_aws.sh`:**

```bash
# [teardown_aws.sh content as provided earlier]
```

**Make the script executable:**

```bash
chmod +x teardown_aws.sh
```

**Run the script:**

```bash
./teardown_aws.sh
```

**Notes:**

- The teardown script deletes the CloudFormation stack and the ECR repository.
- Ensure you have backups or snapshots if necessary before deleting resources.
- The script is idempotent and provides feedback on each action.
- **References:**
  - [AWS CloudFormation Stack Deletion](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html)
  - [AWS ECR Repository Deletion](https://docs.aws.amazon.com/AmazonECR/latest/userguide/delete_repositories.html)

---

## **13. Testing the Application**

After updating the DNS settings and implementing HTTPS, test the application using the domain name over HTTPS.

**Using cURL:**

```bash
curl -X POST "https://api.fountain.coach/sequence" \
-H "Content-Type: application/json" \
-d '{"elementType": "script", "elementId": 1}'
```

**Expected Response:**

```json
{
  "sequenceNumber": 1
}
```

---

## **14. Reference Table**

| Step | Objective                                               | Command/Script             | Notes                                                       |
|------|---------------------------------------------------------|----------------------------|-------------------------------------------------------------|
| 1    | Generate code using GPT-4 via OpenAI API                | `python generate_code.py`  | Save code files as per the model's response                 |
| 2    | Modify code to adhere to FountainAI norms               | `./modify_code.sh`         | Run script to apply code modifications                      |
| 3    | Initialize GitHub repository                            | `./init_repo.sh`           | Ensure GitHub CLI is authenticated                          |
| 4    | Request SSL/TLS certificate using AWS ACM               | `./request_certificate.sh` | Set up SSL certificate for HTTPS                            |
| 5    | Deploy service to AWS using CloudFormation with HTTPS   | `./deploy_to_aws.sh`       | Configure AWS CLI and replace placeholders                  |
| 6    | Update DNS settings using AWS CLI and Route53           | `./update_dns.sh`          | Replace placeholders and ensure AWS CLI permissions         |
| 7    | Test deployed service via HTTPS domain                  | cURL command               | Verify service is working with HTTPS                        |
| 8    | Tear down AWS deployments using CloudFormation          | `./teardown_aws.sh`        | Deletes AWS resources safely                                |
| 9    | **Estimate AWS Costs**                                  | `./estimate_costs.sh`      | Estimate costs for AWS resources used                       |

---

## **15. Conclusion**

By following this workbook, you've:

- Generated code for the Central Sequence Service using GPT-4 via the OpenAI API, utilizing the actual OpenAPI specification from the FountainAI repository.
- Modified the code using shell scripts that adhere to FountainAI norms and the shell scripting style guide.
- Initialized a GitHub repository for the service using `gh` CLI.
- Requested an SSL/TLS certificate using AWS Certificate Manager (ACM) to secure your service with HTTPS.
- Deployed the service to AWS ECS using AWS CLI and CloudFormation, including HTTPS configuration.
- Configured DNS settings in AWS Route53 using AWS CLI to map the domain **fountain.coach** to your service.
- Tested the deployed application to ensure it's functioning correctly via the HTTPS domain name.
- Created tear-down scripts to safely remove AWS deployments using CloudFormation.
- **Estimated AWS costs** using a cost calculation script to understand the financial implications.

---

## **16. Next Steps**

- **Set Up Continuous Deployment**: Automate the entire process using CI/CD pipelines like AWS CodePipeline or GitHub Actions. [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
- **Monitor DNS Records**: Ensure DNS records are up-to-date if the underlying service endpoints change.
- **Expand to Other Services**: Apply the same process to other FountainAI services, updating DNS records accordingly.
- **Scaling and Load Balancing**: Configure auto-scaling policies and ensure your load balancer is properly set up to handle traffic spikes. [AWS Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
- **Enhance Teardown Procedures**: Incorporate additional checks and backups before tearing down resources.

---

## **17. Appendix A: AWS Cost Estimation**

### **17.1 Importance of Cost Estimation**

Estimating AWS costs is crucial to understand the financial implications of deploying and running your services. AWS offers a pay-as-you-go model, and costs can accumulate based on resource usage. This section provides a script to help you estimate the costs associated with the AWS resources used in this workbook.

### **17.2 AWS Cost Estimation Script**

**Create `estimate_costs.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

AWS_REGION="us-east-1"
SERVICE_NAME="central_sequence_service"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME="$SERVICE_NAME"

# Function to estimate costs
estimate_costs() {
    echo "Estimating AWS costs for $SERVICE_NAME..."

    # Variables for estimation
    ECR_STORAGE_GB=0.5 # Estimated storage in GB for Docker images
    ECS_TASK_COUNT=1
    ECS_TASK_CPU=0.25 # vCPU
    ECS_TASK_MEMORY=0.5 # GB
    LOAD_BALANCER_HOURS=730 # Assuming 24/7 usage
    DATA_TRANSFER_GB=10 # Monthly data transfer in GB

    # AWS Pricing (as of current date, please verify with AWS Pricing)
    ECR_STORAGE_COST_PER_GB=$0.10 # per GB-month
    ECS_FARGATE_CPU_COST_PER_HOUR=$0.04048 # per vCPU-hour
    ECS_FARGATE_MEMORY_COST_PER_HOUR=$0.004445 # per GB-hour
    ALB_COST_PER_HOUR=$0.0225 # per hour
    ALB_LCU_COST_PER_HOUR=$0.008 # per LCU-hour
    DATA_TRANSFER_COST_PER_GB=$0.09 # per GB

    # Calculations
    ECR_STORAGE_COST=$(echo "$ECR_STORAGE_GB * $ECR_STORAGE_COST_PER_GB" | bc -l)
    ECS_CPU_COST=$(echo "$ECS_TASK_COUNT * $ECS_TASK_CPU * $ECS_FARGATE_CPU_COST_PER_HOUR * $LOAD_BALANCER_HOURS" | bc -l)
    ECS_MEMORY_COST=$(echo "$ECS_TASK_COUNT * $ECS_TASK_MEMORY * $ECS_FARGATE_MEMORY_COST_PER_HOUR * $LOAD_BALANCER_HOURS" | bc -l)
    ALB_USAGE_COST=$(echo "$ALB_COST_PER_HOUR * $LOAD_BALANCER_HOURS" | bc -l)
    ALB_LCU_COST=$(echo "$ALB_LCU_COST_PER_HOUR * $LOAD_BALANCER_HOURS" | bc -l)
    DATA_TRANSFER_COST=$(echo "$DATA_TRANSFER_GB * $DATA_TRANSFER_COST_PER_GB" | bc -l)

    TOTAL_ECS_COST=$(echo "$ECS_CPU_COST + $ECS_MEMORY_COST" | bc -l)
    TOTAL_ALB_COST=$(echo "$ALB_USAGE_COST + $ALB_LCU_COST" | bc -l)
    TOTAL_COST=$(echo "$ECR_STORAGE_COST + $TOTAL_ECS_COST + $TOTAL_ALB_COST + $DATA_TRANSFER_COST" | bc -l)

    # Output
    echo "Estimated Monthly Costs:"
    echo "ECR Storage: \$$ECR_STORAGE_COST"
    echo "ECS Fargate (CPU + Memory): \$$TOTAL_ECS_COST"
    echo "Application Load Balancer: \$$TOTAL_ALB_COST"
    echo "Data Transfer OUT: \$$DATA_TRANSFER_COST"
    echo "-----------------------------"
    echo "Total Estimated Cost: \$$TOTAL_COST per month"

    echo "Note: These are estimated costs. Actual costs may vary based on usage."
}

# Execute the cost estimation
estimate_costs
```

**Make the script executable:**

```bash
chmod +x estimate_costs.sh
```

**Run the script:**

```bash
./estimate_costs.sh
```

**Notes:**

- **Variables**: Adjust the variables like `ECR_STORAGE_GB`, `ECS_TASK_COUNT`, `ECS_TASK_CPU`, `ECS_TASK_MEMORY`, `LOAD_BALANCER_HOURS`, and `DATA_TRANSFER_GB` based on your expected usage.
- **Pricing**: The prices used are examples and may not reflect the current AWS pricing. Always check the [AWS Pricing Page](https://aws.amazon.com/pricing/) for up-to-date information.
- **Calculation Tool**: This script uses basic calculations with `bc`. Ensure `bc` is installed on your system.
- **Disclaimer**: This is an estimation tool and should be used as a guide. Actual costs may vary based on actual resource usage and AWS pricing changes.
- **References**:
  - [AWS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
  - [Amazon ECR Pricing](https://aws.amazon.com/ecr/pricing/)
  - [Elastic Load Balancing Pricing](https://aws.amazon.com/elasticloadbalancing/pricing/)
  - [AWS Data Transfer Pricing](https://aws.amazon.com/ec2/pricing/on-demand/#Data_Transfer)

---

**Feel free to refer back to this workbook whenever you need guidance on generating, deploying, and managing FountainAI services using GPT-4 via the OpenAI API, AWS CLI, CloudFormation, and Route53, ensuring secure communication through HTTPS at all stages, and understanding the associated AWS costs.**