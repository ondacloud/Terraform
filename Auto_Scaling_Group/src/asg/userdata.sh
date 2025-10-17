#!/bin/bash
yum update -y
yum install --allowerasing -y jq curl wget unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# sed -i 's|PasswordAuthentication no|PasswordAuthentication yes|' /etc/ssh/sshd_config
# echo 'Port 22' >> /etc/ssh/sshd_config
# systemctl restart sshd
# echo 'Skill53##' | passwd --stdin ec2-user
# echo 'Skill53##' | passwd --stdin root