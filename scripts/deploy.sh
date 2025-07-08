#!/bin/bash
set -e

echo "============================"
echo "STEP 1: Check/install Docker"
echo "============================"
if ! command -v docker &> /dev/null; then
  echo "[INFO] Docker not found. Installing Docker..."
  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  echo "[INFO] Docker installed."
else
  echo "[INFO] Docker already installed."
fi

echo "============================"
echo "STEP 2: Check/install Docker Compose"
echo "============================"
if ! command -v docker-compose &> /dev/null; then
  echo "[INFO] Docker Compose not found. Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "[INFO] Docker Compose installed."
else
  echo "[INFO] Docker Compose already installed."
fi

echo "============================"
echo "STEP 3: AWS ECR Login"
echo "============================"
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin 339495302685.dkr.ecr.ap-south-1.amazonaws.com
echo "[INFO] AWS ECR login complete."

cd /home/ec2-user/deployment-infra

echo "============================"
echo "STEP 4: Pull Docker images"
echo "============================"
docker-compose pull
echo "[INFO] Docker images pulled."

echo "============================"
echo "STEP 5: Shut down existing containers"
echo "============================"
docker-compose down || true
echo "[INFO] Existing containers shut down."

echo "============================"
echo "STEP 6: Start Docker Compose stack"
echo "============================"
docker-compose up -d
echo "[INFO] Docker Compose stack started."

echo "============================"
echo "DEPLOYMENT COMPLETE"
echo "============================"
