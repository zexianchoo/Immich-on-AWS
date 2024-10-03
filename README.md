# Immich-on-AWS

An AWS solution to deploy immich, the open source image hosting solution (immich.app) on AWS, since it is currently only supporting local hosting over local networks.
Utilizes Terragrunt, Terraform, and Docker
Saves costs by using Fargate!

# Setup:

## 1. Update app/.env by following `.env.example`:

`acc_num` = your AWS account number

`DB_PASSWORD` = the password you wish to use to access the postgreSQL database

Then, run:
```
bash build_and_push.sh
```
This will push the most recent images into your ECR repository on AWS (will create one for you if you dont have one)

## 2. Set up AWS Credentials

On the top right of the AWS landing page, click on your account and go to Security Credentials.
There, create an Access Key, and note down your corresponding Secret Access Key.
Then, run this in the terminal:
```
export AWS_ACCESS_KEY_ID=<your_access_key_id>
export AWS_SECRET_ACCESS_KEY=<your_secret_access_key>
export AWS_DEFAULT_REGION=us-east-1
```
---

# To Run:
```
cd infrastructure/environments/dev
terragrunt run-all apply
```

# To Access:
```
Check the EC2 instances and locate the fargate service running for immich, `immich-ecs-dev`
Note down the assigned ip and connect to <assigned_ip:2283>

```

# To destroy infrastructure:
```
cd infrastructure/environments/dev
terragrunt run-all destroy
```
