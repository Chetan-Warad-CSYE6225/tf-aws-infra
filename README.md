# Terraform AWS Infra

This project sets up and manages AWS infrastructure using **Terraform**. The configuration files provided define the resources and variables needed to create and manage an environment in AWS.

## Setup Instructions

1. Initialize the Terraform project:

    ```bash
    terraform init

2. Format Terraform files
    ```bash
    terraform fmt

3. Validate the Terraform configuration

    ```bash
    terraform validate

4. Plan the infrastructure changes
    ```bash
    terraform plan


5. Apply the Terraform configuration
    ```bash
    terraform apply

6. Destroy the infrastructure
    ```bash
    terraform destroy


7. Import Certificate
aws acm import-certificate ^
  --certificate fileb://C:\path_to_your_certificate\demo_chetanwarad_me.crt ^
  --private-key fileb://C:\path_to_your_certificate\privatekey.pem ^
  --certificate-chain fileb://C:\path_to_your_certificate\demo_chetanwarad_me.ca-bundle ^
  --region us-east-1 ^
  --profile demo
