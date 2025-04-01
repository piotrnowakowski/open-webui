#!/bin/bash

# Configuration
VPS_USER="root"
VPS_HOST="2a01:4f9:3a:1288::203"
VPS_PATH="/opt/open-webui"
BUILD_DIR="open-webui-build"
IMAGE_NAME="open-webui:prod"
DEPLOY_PACKAGE="open-webui-deploy.tar.gz"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting Open WebUI deployment process...${NC}"

# Create build directory
echo "Creating build directory..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Copy necessary files
echo "Copying configuration files..."
cp ../Dockerfile .
cp ../docker-compose.prod.yaml .
cp ../.env.example .env

# Build Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME .

# Save Docker image
echo "Saving Docker image..."
docker save $IMAGE_NAME > open-webui-prod.tar

# Create deployment package
echo "Creating deployment package..."
tar -czf $DEPLOY_PACKAGE \
    open-webui-prod.tar \
    docker-compose.prod.yaml \
    .env

# Copy to VPS
echo "Copying to VPS..."
scp $DEPLOY_PACKAGE $VPS_USER@$VPS_HOST:$VPS_PATH/

# Deploy on VPS
echo "Deploying on VPS..."
ssh $VPS_USER@$VPS_HOST "cd $VPS_PATH && \
    tar -xzf $DEPLOY_PACKAGE && \
    docker load < open-webui-prod.tar && \
    docker-compose -f docker-compose.prod.yaml up -d"

# Cleanup
echo "Cleaning up..."
cd ..
rm -rf $BUILD_DIR

echo -e "${GREEN}Deployment completed successfully!${NC}" 