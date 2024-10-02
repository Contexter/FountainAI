# **FountainAI Code Generation Workbook**

This workbook provides a comprehensive guide to generating, modifying, and deploying FountainAI services using OpenAI's GPT-4 model via the OpenAI API. The focus is on creating a scripted dialogue with the model to generate code based on versioned OpenAPI specifications. We'll also use shell scripts to automate code modifications, following the FountainAI norms.

---

## **Table of Contents**

1. [Introduction](#1-introduction)
2. [Prerequisites](#2-prerequisites)
3. [Project Setup](#3-project-setup)
4. [Defining Versioned OpenAPI Specifications](#4-defining-versioned-openapi-specifications)
5. [Code Generation with GPT-4 via OpenAI API](#5-code-generation-with-gpt-4-via-openai-api)
   - [5.1 Setting Up the OpenAI API Client](#51-setting-up-the-openai-api-client)
   - [5.2 Generating Code for Central Sequence Service](#52-generating-code-for-central-sequence-service)
6. [Modifying Code with Shell Scripts](#6-modifying-code-with-shell-scripts)
   - [6.1 FountainAI Shell Scripting Guidelines](#61-fountainai-shell-scripting-guidelines)
   - [6.2 Modification Script for Central Sequence Service](#62-modification-script-for-central-sequence-service)
7. [Initializing GitHub Repositories](#7-initializing-github-repositories)
   - [7.1 Using GitHub CLI](#71-using-github-cli)
8. [Deploying Services to AWS](#8-deploying-services-to-aws)
   - [8.1 Deployment Script Following FountainAI Norms](#81-deployment-script-following-fountainai-norms)
9. [Managing DNS Settings with AWS CLI and Route53](#9-managing-dns-settings-with-aws-cli-and-route53)
   - [9.1 Configuring Route53 for fountain.coach](#91-configuring-route53-for-fountaincoach)
   - [9.2 Automating DNS Management with Shell Scripts](#92-automating-dns-management-with-shell-scripts)
10. [Testing the Application](#10-testing-the-application)
11. [Reference Table](#11-reference-table)
12. [Conclusion](#12-conclusion)
13. [Next Steps](#13-next-steps)

---

## **1. Introduction**

This workbook demonstrates how to generate fully-fledged, deployable, and testable FastAPI applications for FountainAI services by interacting with GPT-4 via the OpenAI API. By following the steps outlined, you will:

- Generate code for each service using GPT-4 with scripted API calls.
- Modify the code using shell scripts that adhere to FountainAI norms.
- Initialize GitHub repositories using `gh` CLI.
- Deploy services to AWS using `aws` CLI, following FountainAI guidelines.
- **Manage DNS settings using AWS CLI for Route53 to configure the domain fountain.coach.**

---

## **2. Prerequisites**

Ensure you have the following:

- **OpenAI API Access**: An API key with access to GPT-4.
- **GitHub CLI (`gh`)**: Installed and authenticated.
- **AWS CLI (`aws`)**: Installed and configured with appropriate permissions.
- **Python 3.7+**: Installed.
- **Docker and Docker Compose**: Installed.
- **FountainAI Guide**: Familiarity with FountainAI norms and shell scripting guidelines.
- **Domain Ownership**: You own the domain **fountain.coach** and have access to its DNS settings.

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

Define OpenAPI specifications for each service, ensuring versioning in paths and operation IDs.

### **Example: Central Sequence Service API**

Create a directory for OpenAPI specs:

```bash
mkdir openapi_specs
```

Create `openapi_specs/central_sequence_service_v1.yaml`:

```yaml
openapi: 3.0.0
info:
  title: Central Sequence Service API
  version: "1.0.0"
  description: API for managing sequence numbers.

paths:
  /v1/sequence:
    post:
      summary: Generate Sequence Number
      operationId: generate_sequence_number_v1
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SequenceRequest'
      responses:
        '201':
          description: Sequence number created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SequenceResponse'

components:
  schemas:
    SequenceRequest:
      type: object
      properties:
        elementType:
          type: string
        elementId:
          type: integer
      required:
        - elementType
        - elementId
    SequenceResponse:
      type: object
      properties:
        sequenceNumber:
          type: integer
      required:
        - sequenceNumber
```

Repeat similar steps for the other services, ensuring versioning in the paths and operation IDs.

---

## **5. Code Generation with GPT-4 via OpenAI API**

### **5.1 Setting Up the OpenAI API Client**

Create a Python script `generate_code.py` that will interact with the OpenAI API to generate code based on the OpenAPI specification.

**Install OpenAI Python Library:**

```bash
pip install openai
```

### **5.2 Generating Code for Central Sequence Service**

**Create `generate_code.py`:**

```python
import os
import openai
import yaml

# Load OpenAI API key from environment variable
openai.api_key = os.getenv("OPENAI_API_KEY")

def generate_code(service_name, openapi_spec_path):
    print(f"Generating code for {service_name}...")

    # Load OpenAPI specification
    with open(openapi_spec_path, 'r') as f:
        openapi_spec = f.read()

    # Construct the prompt
    prompt = f"""
You are an expert Python developer specializing in FastAPI and SQLAlchemy. Generate a complete, deployable, and testable FastAPI application for the "{service_name}" based on the following OpenAPI specification. Include:

- Pydantic models for request and response bodies.
- SQLAlchemy models for database tables.
- Endpoint implementations with proper database interactions.
- Versioned API routes as specified in the OpenAPI paths.
- Necessary imports and application setup.
- A Dockerfile for containerization.
- A requirements.txt file with all dependencies.
- A basic test suite using pytest.
- Use environment variables for configuration (e.g., database URL).
- Include logging setup using Python's logging module.
- Ensure code follows FountainAI coding norms.

OpenAPI Specification:
{openapi_spec}

Provide the code in separate files with proper file names. Use triple backticks with language identifiers for code blocks, e.g., ```python, ```Dockerfile, or ```yaml.
"""

    # Call the OpenAI API
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "user", "content": prompt}
        ],
        max_tokens=3000,
        temperature=0
    )

    # Extract the generated code
    code = response['choices'][0]['message']['content']

    # Save the generated code to files
    save_generated_code(service_name, code)

def save_generated_code(service_name, code):
    import re

    # Create the service directory
    service_dir = os.path.join("services", service_name)
    os.makedirs(service_dir, exist_ok=True)

    # Regular expression to find code blocks
    code_blocks = re.findall(r'```(\w+)?\n(.*?)```', code, re.DOTALL)

    if not code_blocks:
        print("No code blocks found in the response.")
        return

    for language, content in code_blocks:
        # Extract filename from the content
        filename_match = re.match(r'#\s*(.*?)\n', content)
        if filename_match:
            filename = filename_match.group(1).strip()
            file_content = content[filename_match.end():]
        else:
            # Default filename if not specified
            filename = f"code.{language.strip() if language else 'txt'}"
            file_content = content

        # Remove any leading/trailing whitespace
        file_content = file_content.strip()

        # Save the file
        file_path = os.path.join(service_dir, filename)
        with open(file_path, 'w') as f:
            f.write(file_content)

        print(f"Generated {filename}")

if __name__ == "__main__":
    generate_code(
        service_name="central_sequence_service",
        openapi_spec_path="openapi_specs/central_sequence_service_v1.yaml"
    )
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

## **6. Modifying Code with Shell Scripts**

### **6.1 FountainAI Shell Scripting Guidelines**

According to the FountainAI guide:

- Shell scripts should be executable (`chmod +x script.sh`).
- Use `set -e` to exit immediately if a command exits with a non-zero status.
- Include comments explaining each section of the script.
- Scripts should be idempotent where possible.
- Use environment variables for configuration.
- Follow best practices for readability and maintainability.

### **6.2 Modification Script for Central Sequence Service**

**Create `modify_code.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the service name
SERVICE_NAME="central_sequence_service"

# Navigate to the service directory
cd "services/$SERVICE_NAME"

echo "Modifying code for $SERVICE_NAME to adhere to FountainAI norms..."

# Install required tools
pip install black flake8 isort

# Format code with black
black .

# Sort imports with isort
isort .

# Lint code with flake8
flake8 .

# Ensure environment variables are used for configuration
sed -i "s|'sqlite:///./central_sequence_service.db'|os.getenv('DATABASE_URL', 'sqlite:///./${SERVICE_NAME}.db')|" database.py

# Add logging setup to main.py if not already present
if ! grep -q "logging.basicConfig" main.py; then
    sed -i '/import logging/a logging.basicConfig(level=logging.INFO)' main.py
fi

echo "Code modification for $SERVICE_NAME completed."

# Return to the root directory
cd ../../
```

**Make the script executable:**

```bash
chmod +x modify_code.sh
```

**Run the script:**

```bash
./modify_code.sh
```

---

## **7. Initializing GitHub Repositories**

### **7.1 Using GitHub CLI**

**Create `init_repo.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the service name and GitHub username
SERVICE_NAME="central_sequence_service"
GITHUB_USERNAME="yourusername"

# Navigate to the service directory
cd "services/$SERVICE_NAME"

echo "Initializing Git repository for $SERVICE_NAME..."

# Initialize git repository
git init

# Add all files and commit
git add .
git commit -m "Initial commit for $SERVICE_NAME"

# Create GitHub repository using gh CLI
gh repo create "$GITHUB_USERNAME/$SERVICE_NAME" --public --source=. --remote=origin

# Push code to GitHub
git branch -M main
git push -u origin main

echo "GitHub repository for $SERVICE_NAME initialized and code pushed."

# Return to the root directory
cd ../../
```

**Make the script executable:**

```bash
chmod +x init_repo.sh
```

**Run the script:**

```bash
./init_repo.sh
```

---

## **8. Deploying Services to AWS**

### **8.1 Deployment Script Following FountainAI Norms**

**Create `deploy_to_aws.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
SERVICE_NAME="central_sequence_service"
AWS_REGION="us-east-1"
CLUSTER_NAME="fountainai-cluster"
ECR_REPO_NAME="$SERVICE_NAME"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest"

# Authenticate Docker to AWS ECR
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Navigate to the service directory
cd "services/$SERVICE_NAME"

echo "Building Docker image for $SERVICE_NAME..."

# Build Docker image
docker build -t "$ECR_REPO_NAME" .

# Tag the image
docker tag "$ECR_REPO_NAME:latest" "$IMAGE_URI"

echo "Pushing Docker image to ECR..."

# Create ECR repository if it doesn't exist
aws ecr describe-repositories --repository-names "$ECR_REPO_NAME" --region "$AWS_REGION" || aws ecr create-repository --repository-name "$ECR_REPO_NAME" --region "$AWS_REGION"

# Push image to ECR
docker push "$IMAGE_URI"

echo "Deploying $SERVICE_NAME to AWS ECS..."

# Create ECS cluster if it doesn't exist
aws ecs describe-clusters --clusters "$CLUSTER_NAME" --region "$AWS_REGION" || aws ecs create-cluster --cluster-name "$CLUSTER_NAME" --region "$AWS_REGION"

# Register task definition
cat > taskdef.json << EOF
{
  "family": "$SERVICE_NAME",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "$SERVICE_NAME",
      "image": "$IMAGE_URI",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "DATABASE_URL",
          "value": "your-database-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/$SERVICE_NAME",
          "awslogs-region": "$AWS_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512"
}
EOF

echo "Registering task definition..."

aws ecs register-task-definition \
    --cli-input-json file://taskdef.json \
    --region "$AWS_REGION"

# Create or update ECS service
SERVICE_EXISTS=$(aws ecs describe-services --cluster "$CLUSTER_NAME" --services "$SERVICE_NAME" --region "$AWS_REGION" --query 'services[0].status' --output text 2>/dev/null || echo "MISSING")

if [ "$SERVICE_EXISTS" == "ACTIVE" ]; then
    echo "Updating existing ECS service..."
    aws ecs update-service \
        --cluster "$CLUSTER_NAME" \
        --service "$SERVICE_NAME" \
        --force-new-deployment \
        --task-definition "$SERVICE_NAME" \
        --region "$AWS_REGION"
else
    echo "Creating new ECS service..."
    aws ecs create-service \
        --cluster "$CLUSTER_NAME" \
        --service-name "$SERVICE_NAME" \
        --task-definition "$SERVICE_NAME" \
        --desired-count 1 \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[\"your-subnet-id\"],securityGroups=[\"your-security-group-id\"],assignPublicIp=\"ENABLED\"}" \
        --region "$AWS_REGION"
fi

echo "$SERVICE_NAME deployed to AWS ECS."

# Clean up
rm taskdef.json

# Return to the root directory
cd ../../
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

- Replace placeholders like `your-database-url`, `your-subnet-id`, and `your-security-group-id` with actual values.
- Ensure AWS CLI is configured with appropriate permissions.
- The script handles image pushing to AWS ECR and deployment to AWS ECS.

---

## **9. Managing DNS Settings with AWS CLI and Route53**

### **9.1 Configuring Route53 for fountain.coach**

#### **Prerequisites**

- **Ownership of the domain fountain.coach**: Ensure that you own the domain **fountain.coach** and it's registered in AWS Route53 as a hosted zone.
- **AWS CLI Configured**: AWS CLI should be configured with appropriate permissions to manage Route53 resources.

#### **Step 1: Verify the Hosted Zone**

Check if a hosted zone exists for **fountain.coach**:

```bash
aws route53 list-hosted-zones
```

If you see an entry for **fountain.coach**, note the **Hosted Zone ID**. If not, you need to create a hosted zone.

#### **Step 2: Create a Hosted Zone (If Necessary)**

To create a public hosted zone:

```bash
aws route53 create-hosted-zone --name fountain.coach --caller-reference "$(date +%s)"
```

This will return details including the **Hosted Zone ID** and the nameservers assigned to your domain. Update your domain registrar's NS records to point to these nameservers if necessary.

### **9.2 Automating DNS Management with Shell Scripts**

We'll create a shell script to automate the process of updating DNS records using AWS CLI.

**Create `update_dns.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
SERVICE_NAME="central_sequence_service"
DOMAIN_NAME="fountain.coach"
SUBDOMAIN="api"  # Adjust as needed, e.g., 'api', 'service1', etc.
HOSTED_ZONE_ID="YOUR_HOSTED_ZONE_ID"  # Replace with your Hosted Zone ID
AWS_REGION="us-east-1"

# Get the DNS name of the service's load balancer
LOAD_BALANCER_NAME=$(aws ecs describe-services \
    --cluster fountainai-cluster \
    --services "$SERVICE_NAME" \
    --region "$AWS_REGION" \
    --query 'services[0].loadBalancers[0].loadBalancerName' \
    --output text)

if [ "$LOAD_BALANCER_NAME" == "None" ]; then
    echo "No load balancer found for $SERVICE_NAME. Exiting."
    exit 1
fi

# Get the DNS name of the load balancer
LOAD_BALANCER_DNS=$(aws elbv2 describe-load-balancers \
    --names "$LOAD_BALANCER_NAME" \
    --region "$AWS_REGION" \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

if [ -z "$LOAD_BALANCER_DNS" ]; then
    echo "Failed to retrieve Load Balancer DNS Name. Exiting."
    exit 1
fi

echo "Load Balancer DNS: $LOAD_BALANCER_DNS"

# Create a JSON file for the DNS record change
cat > dns_changes.json << EOF
{
    "Comment": "Update record to reflect new Load Balancer DNS",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$SUBDOMAIN.$DOMAIN_NAME.",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "$LOAD_BALANCER_DNS"
                    }
                ]
            }
        }
    ]
}
EOF

# Update the DNS record
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch file://dns_changes.json

echo "DNS record updated. $SUBDOMAIN.$DOMAIN_NAME now points to $LOAD_BALANCER_DNS"

# Clean up
rm dns_changes.json
```

**Make the script executable:**

```bash
chmod +x update_dns.sh
```

**Run the script:**

```bash
./update_dns.sh
```

#### **Notes:**

- **Replace Placeholders:**
  - `YOUR_HOSTED_ZONE_ID`: Replace with your actual Route53 Hosted Zone ID for **fountain.coach**.
  - `SUBDOMAIN`: The subdomain you want to use (e.g., `api`, `service1`).
- **Load Balancer Configuration:**
  - Ensure your ECS service is associated with a load balancer (ALB or NLB).
  - Adjust AWS CLI commands if necessary based on your load balancer type.
- **Public IP Address:**
  - If your service has a public IP address, you can set the record type to `A` and use the IP address directly.

---

## **10. Testing the Application**

After updating the DNS settings, you can test the application using the domain name.

**Using cURL:**

```bash
curl -X POST "https://api.fountain.coach/v1/sequence" \
-H "Content-Type: application/json" \
-d '{"elementType": "scene", "elementId": 1}'
```

**Expected Response:**

```json
{
  "sequenceNumber": 1
}
```

**Notes:**

- **Propagation Time:** DNS changes may take some time to propagate. Wait for a few minutes if you encounter issues.
- **HTTPS Configuration:** If you want to use HTTPS, consider using AWS Certificate Manager (ACM) to provision SSL certificates and configure your load balancer to use them.

---

## **11. Reference Table**

| Step | Objective                                                | Command/Script             | Notes                                                       |
|------|----------------------------------------------------------|----------------------------|-------------------------------------------------------------|
| 1    | Generate code using GPT-4 via OpenAI API                 | `python generate_code.py`  | Save code files as per the model's response                 |
| 2    | Modify code to adhere to FountainAI norms                | `./modify_code.sh`         | Run script to apply code modifications                      |
| 3    | Initialize GitHub repository                             | `./init_repo.sh`           | Ensure GitHub CLI is authenticated                          |
| 4    | Deploy service to AWS                                    | `./deploy_to_aws.sh`       | Configure AWS CLI and replace placeholders                  |
| 5    | Update DNS settings using AWS CLI and Route53            | `./update_dns.sh`          | Replace placeholders and ensure AWS CLI permissions         |
| 6    | Test deployed service via domain                         | cURL command               | Verify service is working with the domain                   |

---

## **12. Conclusion**

By following this workbook, you've:

- Generated code for the Central Sequence Service using GPT-4 via the OpenAI API.
- Modified the code using a shell script that adheres to FountainAI norms.
- Initialized a GitHub repository for the service using `gh` CLI.
- Deployed the service to AWS ECS using AWS CLI.
- **Configured DNS settings in AWS Route53 using AWS CLI to map the domain fountain.coach to your service.**
- Tested the deployed application to ensure it's functioning correctly via the domain name.

---

## **13. Next Steps**

- **Implement HTTPS:** Secure your service by configuring SSL/TLS certificates using AWS Certificate Manager (ACM).
- **Set Up Continuous Deployment:** Automate the entire process using CI/CD pipelines like AWS CodePipeline or GitHub Actions.
- **Monitor DNS Records:** Ensure DNS records are up-to-date if the underlying service endpoints change.
- **Expand to Other Services:** Apply the same process to other FountainAI services, updating DNS records accordingly.
- **Scaling and Load Balancing:** Configure auto-scaling policies and ensure your load balancer is properly set up to handle traffic.

---

**Important Notes:**

- **Handle Credentials Securely:** Do not hardcode secrets in your code or scripts. Use environment variables or secret management tools like AWS Secrets Manager.
- **Review AWS Costs:** Be aware of potential costs associated with AWS resources like Route53, ECS, ECR, and load balancers.
- **Domain Ownership:** Ensure you have the rights to configure DNS settings for fountain.coach and that your domain registrar's NS records point to AWS Route53 if necessary.
- **OpenAI API Usage:** Be mindful of the OpenAI API usage policies and monitor your API usage to manage costs.

---

**Feel free to refer back to this workbook whenever you need guidance on generating, deploying, and configuring FountainAI services using GPT-4 via the OpenAI API, AWS CLI, and Route53.**