# Flask App Deployment with Terraform

This repository contains Terraform configurations to deploy a Flask application using AWS services such as EC2, RDS, ALB, and API Gateway.

## Application Services

The Flask application exposes the following services:

1. `/process_file` (POST): A service to process a file.
2. `/answer_question` (POST): A service to answer a question.
3. `/healthcheck` (GET): A healthcheck service to check the application status.
4. `/` (GET): The root path of the application.
## Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or later).
2. Configure your [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
3. Add your public SSH key to the `~/.ssh` directory and replace `<your_rsa>` in the `ec2/main.tf` file with the actual name of your RSA public key file.
4. Replace `<path/to/your/public_key.pem>` in the `ec2/main.tf` file with the actual path to your public key file.
5. Replace `<path/to/env_file>` in the `ec2/main.tf` file with the actual path to your environment variables file.

## Deployment

To deploy the infrastructure, follow these steps:

1. Run `terraform init` to initialize the Terraform working directory.
2. Run `terraform apply` to create the infrastructure.

After the infrastructure is deployed, you will receive the API Gateway healthcheck URL as an output.

To destroy the infrastructure when you are done, run `terraform destroy`.
