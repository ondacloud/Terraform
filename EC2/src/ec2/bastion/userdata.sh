#!/bin/bash
yum update -y
yum install --allowerasing -y jq curl wget unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# sed -i 's|PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
# echo 'Port 22' >> /etc/ssh/sshd_config
# systemctl restart sshd
# echo 'Skill53##' | passwd --stdin ec2-user
# echo 'Skill53##' | passwd --stdin root