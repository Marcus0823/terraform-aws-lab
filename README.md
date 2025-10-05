# terraform-aws-lab
Terraform AWS lab deploying a VPC with subnet, internet gateway, custom route table, security groups (SSH, HTTP, HTTPS), Elastic IP, and an Ubuntu EC2 instance running Apache2. Automates network setup and web server deployment for hands-on cloud learning.

## Infrastructure Components

- VPC – custom private network
- Subnet – public subnet for EC2
- Internet Gateway – enables internet access
- Route Table – directs traffic to IGW
- Security Groups – allows SSH (22), HTTP (80), HTTPS (443)
- Elastic IP & Network Interface – static public IP for EC2
- EC2 Instance (Ubuntu) – runs Apache2 web server
