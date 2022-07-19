#!/bin/bash
yum install -y docker
systemctl enable docker
systemctl start docker
yum install -y awslogs
systemctl enable awslogsd 
systemctl start awslogsd
docker run -d --log-driver=awslogs --log-opt awslogs-region=us-east-1 --log-opt awslogs-group=epsilon --log-opt awslogs-create-group=true -p 80:3000 --env REACT_APP_API_URL=https://epsilon-smartbankapi.cloudtech-training.com/ anshshrivastava/smartbankfrontend:v4
# docker run -d -p 80:3000 --env REACT_APP_API_URL=http:// anshshrivastava/smartbankfrontend:v4
