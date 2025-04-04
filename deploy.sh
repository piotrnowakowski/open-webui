#!/bin/bash

# Configuration
VPS_USER="root"
VPS_HOST="2a01:4f9:3a:1288::203"
VPS_PATH="/opt/open-webui"
BUILD_DIR="open-webui-build"
IMAGE_NAME="open-webui:prod"
CONTAINER_NAME="open-webui"
DEPLOY_PACKAGE="open-webui-deploy.tar.gz"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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
    # Stop and remove existing container if it exists
    if docker ps -q --filter name=$CONTAINER_NAME | grep -q .; then
        echo 'Stopping existing container...'
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    fi && \
    # Remove existing image if it exists
    if docker images -q $IMAGE_NAME | grep -q .; then
        echo 'Removing existing image...'
        docker rmi $IMAGE_NAME
    fi && \
    # Extract and load new image
    tar -xzf $DEPLOY_PACKAGE && \
    docker load < open-webui-prod.tar && \
    # Run new container
    docker run -d \
        -p 3000:8080 \
        -v open-webui:/app/backend/data \
        --name $CONTAINER_NAME \
        --restart always \
        $IMAGE_NAME && \
    # Clean up deployment files
    rm -f $DEPLOY_PACKAGE open-webui-prod.tar && \
    # Show container status
    echo 'Container status:' && \
    docker ps -a | grep $CONTAINER_NAME"

# Cleanup
echo "Cleaning up..."
cd ..
rm -rf $BUILD_DIR

echo -e "${GREEN}Deployment completed successfully!${NC}" 