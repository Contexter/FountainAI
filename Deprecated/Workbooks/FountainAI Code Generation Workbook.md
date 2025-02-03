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
openapi: 3.1.0
info:
  title: Central Sequence Service API
  description: >
    This API manages the assignment and updating of sequence numbers for various elements within a story, ensuring logical order and consistency.
  version: 1.0.0
servers:
  - url: https://centralsequence.fountain.coach
    description: Production server for Central Sequence Service API
  - url: http://localhost:8080
    description: Development server
paths:
  /sequence:
    post:
      summary: Generate Sequence Number
      operationId: generateSequenceNumber
      description: Generates a new sequence number for a specified element type.
      requestBody:
        required: true
        description: Details of the element requesting a sequence number.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SequenceRequest'
            examples:
              example:
                value:
                  elementType: script
                  elementId: 1
      responses:
        '201':
          description: Sequence number successfully generated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SequenceResponse'
              examples:
                example:
                  value:
                    sequenceNumber: 1
  /sequence/reorder:
    post:
      summary: Reorder Elements
      operationId: reorderElements
      description: Reorders elements by updating their sequence numbers.
      requestBody:
        required: true
        description: Details of the reordering request.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReorderRequest'
            examples:
              example:
                value:
                  elementType: section
                  elements:
                    - elementId: 1
                      newSequence: 2
                    - elementId: 2
                      newSequence: 1
      responses:
        '200':
          description: Elements successfully reordered.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SuccessResponse'
              examples:
                example:
                  value:
                    message: Reorder successful.
  /sequence/version:
    post:
      summary: Create New Version
      operationId: createVersion
      description: Creates a new version of an element.
      requestBody:
        required: true
        description: Details of the versioning request.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/VersionRequest'
            examples:
              example:
                value:
                  elementType: dialogue
                  elementId: 1
                  newVersionData:
                    text: "O Romeo, Romeo! wherefore art thou Romeo?"
      responses:
        '201':
          description: New version successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/VersionResponse'
              examples:
                example:
                  value:
                    versionNumber: 2
components:
  schemas:
    SequenceRequest:
      type: object
      properties:
        elementType:
          type: string
          description: Type of the element (e.g., script, section, character, action, spokenWord).
        elementId:
          type: integer
          description: Unique identifier of the element.
      required: [elementType, elementId]
    SequenceResponse:
      type: object
      properties:
        sequenceNumber:
          type: integer
          description: The generated sequence number.
    ReorderRequest:
      type: object
      properties:
        elementType:
          type: string
          description: Type of elements being reordered.
        elements:
          type: array
          items:
            type: object
            properties:
              elementId:
                type: integer
                description: Unique identifier of the element.
              newSequence:
                type: integer
                description: New sequence number for the element.
      required: [elementType, elements]
    VersionRequest:
      type: object
      properties:
        elementType:
          type: string
          description: Type of the element (e.g., script, section, character, action, spokenWord).
        elementId:
          type: integer
          description: Unique identifier of the element.
        newVersionData:
          type: object
          description: Data for the new version of the element.
      required: [elementType, elementId, newVersionData]
    VersionResponse:
      type: object
      properties:
        versionNumber:
          type: integer
          description: The version number of the new version.
    SuccessResponse:
      type: object
      properties:
        message:
          type: string
          description: Success message.
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
import os
import openai
import re

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
        openapi_spec_path="openapi_specs/central_sequence_service.yaml"
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
#!/bin/bash

# Function to create a configuration file if it does not exist
create_config_file() {
    local config_file="$1"

    # Check if the configuration file already exists
    if [ ! -f "$config_file" ]; then
        # Create the config file with default settings
        echo "Creating configuration file: $config_file"
        cat <<EOL > "$config_file"
# Default Configuration for FountainAI
api_gateway: kong
storage_service: opensearch
EOL
    else
        # If the file exists, notify the user
        echo "Configuration file $config_file already exists."
    fi
}
```

**2. Idempotency**

Ensuring that running a script multiple times results in the same outcome.

**Example:**

```bash
# Function to create a directory if it does not exist
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Directory $1 created."
    else
        echo "Directory $1 already exists."
    fi
}
```

**3. Commenting and Structure**

Scripts should be fully commented, with clear explanations of what each function does and the expected outcome.

**Example:**

```bash
# Function to initialize FountainAI environment by creating directories and setting up configurations
initialize_environment() {
    create_directory "/path/to/project"
    create_config_file "/path/to/project/config.yml"
}
```

**4. Using Shell Scripts as Orchestrators and Code Writers**

Shell scripts in FountainAI have two primary roles:

- **Command Invocation**: Issuing commands that invoke external tools and services.
- **Code Generation (Code Writing)**: Generating code and configuration files deterministically.

**Example of Code Generation:**

```bash
# Function to generate a GitHub Actions workflow YAML file
create_github_workflow() {
    cat <<EOL > .github/workflows/deploy.yml
name: Deploy FountainAI
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Run deployment script
        run: ./deploy.sh
EOL
}
```

---

## **7. Modifying Code with Shell Scripts**

Create a script `modify_code.sh` to modify the generated code according to FountainAI norms.

**Create `modify_code.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SERVICE_NAME="central_sequence_service"
SERVICE_DIR="services/$SERVICE_NAME"

# Function to install required Python tools
install_python_tools() {
    echo "Installing required Python tools..."
    pip install black flake8 isort
}

# Function to format and lint code
format_and_lint_code() {
    echo "Formatting and linting code..."
    black "$SERVICE_DIR"
    isort "$SERVICE_DIR"
    flake8 "$SERVICE_DIR"
}

# Function to update configuration in code files
update_configuration() {
    echo "Updating configuration in code files..."
    local database_file="$SERVICE_DIR/database.py"
    if [ -f "$database_file" ]; then
        sed -i "s|'sqlite:///./${SERVICE_NAME}.db'|os.getenv('DATABASE_URL', 'sqlite:///./${SERVICE_NAME}.db')|" "$database_file"
    fi
}

# Function to add logging setup
add_logging_setup() {
    echo "Adding logging setup..."
    local main_file="$SERVICE_DIR/main.py"
    if [ -f "$main_file" ]; then
        if ! grep -q "logging.basicConfig" "$main_file"; then
            sed -i '/import logging/a logging.basicConfig(level=logging.INFO)' "$main_file"
        fi
    fi
}

# Main function to modify code
modify_code() {
    echo "Modifying code for $SERVICE_NAME to adhere to FountainAI norms..."
    cd "$SERVICE_DIR"
    install_python_tools
    format_and_lint_code
    update_configuration
    add_logging_setup
    echo "Code modification for $SERVICE_NAME completed."
    cd - > /dev/null
}

# Execute the main function
modify_code
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
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SERVICE_NAME="central_sequence_service"
SERVICE_DIR="services/$SERVICE_NAME"
GITHUB_USERNAME="yourusername" # Replace with your GitHub username

# Function to initialize Git repository
initialize_git_repository() {
    echo "Initializing Git repository for $SERVICE_NAME..."
    cd "$SERVICE_DIR"
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial commit for $SERVICE_NAME"
        echo "Git repository initialized."
    else
        echo "Git repository already initialized."
    fi
    cd - > /dev/null
}

# Function to create GitHub repository
create_github_repository() {
    echo "Creating GitHub repository for $SERVICE_NAME..."
    cd "$SERVICE_DIR"
    if ! git remote | grep -q origin; then
        gh repo create "$GITHUB_USERNAME/$SERVICE_NAME" --public --source=. --remote=origin
        git branch -M main
        git push -u origin main
        echo "GitHub repository created and code pushed."
    else
        echo "Remote origin already exists."
    fi
    cd - > /dev/null
}

# Main function to initialize repository
initialize_repository() {
    initialize_git_repository
    create_github_repository
}

# Execute the main function
initialize_repository
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
- Remember to replace `yourusername` with your actual GitHub username.

---

## **9. Deploying Services to AWS**

Deploy the service to AWS using AWS CLI and CloudFormation, following FountainAI norms.

**Create `deploy_to_aws.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SERVICE_NAME="central_sequence_service"
SERVICE_DIR="services/$SERVICE_NAME"
AWS_REGION="us-east-1"
STACK_NAME="${SERVICE_NAME}-stack"
TEMPLATE_FILE="cloudformation_template.yaml"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME="$SERVICE_NAME"
IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest"

# Function to authenticate Docker to AWS ECR
authenticate_ecr() {
    echo "Authenticating Docker to AWS ECR..."
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
}

# Function to build and push Docker image
build_and_push_image() {
    echo "Building and pushing Docker image for $SERVICE_NAME..."
    cd "$SERVICE_DIR"
    docker build -t "$ECR_REPO_NAME" .
    docker tag "$ECR_REPO_NAME:latest" "$IMAGE_URI"
    aws ecr describe-repositories --repository-names "$ECR_REPO_NAME" --region "$AWS_REGION" || aws ecr create-repository --repository-name "$ECR_REPO_NAME" --region "$AWS_REGION"
    docker push "$IMAGE_URI"
    cd - > /dev/null
}

# Function to create CloudFormation template
create_cloudformation_template() {
    echo "Creating CloudFormation template with HTTPS support..."
    CERTIFICATE_ARN=$(cat certificate_arn.txt)

    cat > "$TEMPLATE_FILE" << EOF
AWSTemplateFormatVersion: '2010-09-09'
Description: CloudFormation template for $SERVICE_NAME with HTTPS

Parameters:
  VPCId:
    Type: AWS::EC2::VPC::Id
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>

Resources:
  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: fountainai-cluster
  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: $SERVICE_NAME
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      Cpu: 256
      Memory: 512
      ExecutionRoleArn: arn:aws:iam::${AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole
      ContainerDefinitions:
        - Name: $SERVICE_NAME
          Image: $IMAGE_URI
          Essential: true
          PortMappings:
            - ContainerPort: 8000
              Protocol: tcp
          Environment:
            - Name: DATABASE_URL
              Value: your-database-url
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: /ecs/$SERVICE_NAME
              awslogs-region: $AWS_REGION
              awslogs-stream-prefix: ecs
  Service:
    Type: AWS::ECS::Service
    Properties:
      ServiceName: $SERVICE_NAME
      Cluster: !Ref ECSCluster
      TaskDefinition: !Ref TaskDefinition
      DesiredCount: 1
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          AssignPublicIp: ENABLED
          Subnets: !Ref SubnetIds
          SecurityGroups:
            - your-security-group-id
      LoadBalancers:
        - ContainerName: $SERVICE_NAME
          ContainerPort: 8000
          TargetGroupArn: !Ref TargetGroup
  LoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: ${SERVICE_NAME}-lb
      Subnets: !Ref SubnetIds
      SecurityGroups:
        - your-security-group-id
      Scheme: internet-facing
      Type: application
  Listener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref LoadBalancer
      Port: 443
      Protocol: HTTPS
      Certificates:
        - CertificateArn: $CERTIFICATE_ARN
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: ${SERVICE_NAME}-tg
      Port: 8000
      Protocol: HTTP
      VpcId: !Ref VPCId
      TargetType: ip
      HealthCheckProtocol: HTTP
      HealthCheckPort: '8000'
      HealthCheckPath: '/'
Outputs:
  LoadBalancerDNSName:
    Description: "The DNS name of the load balancer"
    Value: !GetAtt LoadBalancer.DNSName
EOF
}

# Function to deploy CloudFormation stack
deploy_cloudformation_stack() {
    echo "Deploying CloudFormation stack with HTTPS support..."

    aws cloudformation deploy \
        --template-file "$TEMPLATE_FILE" \
        --stack-name "$STACK_NAME" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
            VPCId=your-vpc-id \
            SubnetIds=your-subnet-ids \
        --region "$AWS_REGION"
}

# Main function to deploy the service
deploy_service() {
    authenticate_ecr
    build_and_push_image
    create_cloudformation_template
    deploy_cloudformation_stack
    echo "$SERVICE_NAME deployed using CloudFormation."
}

# Execute the main function
deploy_service
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
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SERVICE_NAME="central_sequence_service"
DOMAIN_NAME="fountain.coach"
SUBDOMAIN="api"
HOSTED_ZONE_ID="YOUR_HOSTED_ZONE_ID" # Replace with your actual Hosted Zone ID
AWS_REGION="us-east-1"

# Function to retrieve Load Balancer DNS
get_load_balancer_dns() {
    echo "Retrieving Load Balancer DNS..."
    LOAD_BALANCER_DNS=$(aws cloudformation describe-stacks \
        --stack-name "${SERVICE_NAME}-stack" \
        --region "$AWS_REGION" \
        --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDNSName'].OutputValue" \
        --output text)

    if [ -z "$LOAD_BALANCER_DNS" ]; then
        echo "No Load Balancer DNS found."
        exit 1
    fi
}

# Function to update DNS record
update_dns_record() {
    echo "Updating DNS record..."
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
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch file://dns_changes.json
    rm dns_changes.json
    echo "DNS record updated: $SUBDOMAIN.$DOMAIN_NAME -> $LOAD_BALANCER_DNS"
}

# Main function to update DNS
update_dns() {
    get_load_balancer_dns
    update_dns_record
}

# Execute the main function
update_dns
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
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

DOMAIN_NAME="fountain.coach"
SUBDOMAIN="api"
AWS_REGION="us-east-1"
CERTIFICATE_ARN_FILE="certificate_arn.txt"

# Function to request a certificate
request_certificate() {
    echo "Requesting SSL/TLS certificate for $SUBDOMAIN.$DOMAIN_NAME..."

    CERTIFICATE_ARN=$(aws acm request-certificate \
        --domain-name "$SUBDOMAIN.$DOMAIN_NAME" \
        --validation-method DNS \
        --region "$AWS_REGION" \
        --query CertificateArn \
        --output text)

    echo "Certificate ARN: $CERTIFICATE_ARN"

    echo "$CERTIFICATE_ARN" > "$CERTIFICATE_ARN_FILE"
}

# Function to validate the certificate
validate_certificate() {
    echo "Validating certificate..."

    CERTIFICATE_ARN=$(cat "$CERTIFICATE_ARN_FILE")

    # Get DNS validation options
    VALIDATION_OPTIONS=$(aws acm describe-certificate \
        --certificate-arn "$CERTIFICATE_ARN" \
        --region "$AWS_REGION" \
        --query "Certificate.DomainValidationOptions[0].ResourceRecord")

    # Extract Name and Value for DNS record
    RECORD_NAME=$(echo "$VALIDATION_OPTIONS" | jq -r '.Name')
    RECORD_VALUE=$(echo "$VALIDATION_OPTIONS" | jq -r '.Value')

    echo "Adding DNS validation record to Route53..."

    # Create DNS validation record
    cat > dns_validation.json << EOF
{
    "Comment": "Adding validation record for ACM certificate",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$RECORD_NAME",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "$RECORD_VALUE"
                    }
                ]
            }
        }
    ]
}
EOF

    HOSTED_ZONE_ID="YOUR_HOSTED_ZONE_ID" # Replace with your actual Hosted Zone ID

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch file://dns_validation.json

    rm dns_validation.json

    echo "Waiting for certificate validation..."
    aws acm wait certificate-validated \
        --certificate-arn "$CERTIFICATE_ARN" \
        --region "$AWS_REGION"

    echo "Certificate validated."
}

# Main function to request and validate certificate
setup_certificate() {
    request_certificate
    validate_certificate
}

# Execute the main function
setup_certificate
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

Update the `create_cloudformation_template` function in `deploy_to_aws.sh` as shown above.

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
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

STACK_NAME="central_sequence_service-stack"
AWS_REGION="us-east-1"
ECR_REPO_NAME="central_sequence_service"

# Function to delete CloudFormation stack
delete_cloudformation_stack() {
    echo "Deleting CloudFormation stack..."
    aws cloudformation delete-stack \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION"
    echo "Waiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION"
    echo "CloudFormation stack deleted."
}

# Function to delete ECR repository
delete_ecr_repository() {
    echo "Deleting ECR repository..."
    aws ecr delete-repository \
        --repository-name "$ECR_REPO_NAME" \
        --force \
        --region "$AWS_REGION"
    echo "ECR repository deleted."
}

# Main function to teardown AWS resources
teardown_resources() {
    delete_cloudformation_stack
    delete_ecr_repository
}

# Execute the main function
teardown_resources
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
    ECR_STORAGE_COST_PER_GB=0.10 # per GB-month
    ECS_FARGATE_CPU_COST_PER_HOUR=0.04048 # per vCPU-hour
    ECS_FARGATE_MEMORY_COST_PER_HOUR=0.004445 # per GB-hour
    ALB_COST_PER_HOUR=0.0225 # per hour
    ALB_LCU_COST_PER_HOUR=0.008 # per LCU-hour
    DATA_TRANSFER_COST_PER_GB=0.09 # per GB

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