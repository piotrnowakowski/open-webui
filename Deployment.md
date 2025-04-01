# Open WebUI Deployment Guide

This guide provides instructions for deploying Open WebUI to a production server.

## Prerequisites

### Local Machine
- Docker installed
- Git installed
- SSH access to the server
- Open WebUI source code

### Server Requirements
- Ubuntu/Debian-based system
- Docker installed
- Docker Compose installed
- At least 2GB RAM
- At least 20GB storage

## Server Setup

1. **Install Docker and Docker Compose**:
```bash
# Update system
apt update && apt upgrade -y

# Install Docker
apt install docker.io -y
systemctl enable docker
systemctl start docker

# Install Docker Compose
apt install docker-compose -y
```

2. **Create Deployment Directory**:
```bash
mkdir -p /opt/open-webui
```

## Local Development Setup

Required environment variables:
```env
# WebUI Configuration
WEBUI_PORT=3000
WEBUI_SECRET_KEY=your-secure-secret-key-here

# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key-here
OPENAI_API_BASE_URL=https://api.openai.com/v1

# Security Configuration
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=your-secure-admin-password-here
ALLOWED_ORIGINS=http://localhost:3000,https://your-domain.com
```

## Deployment Process

1. **Make the Deployment Script Executable**:
```bash
chmod +x deploy.sh
```

2. **Run the Deployment Script**:
```bash
./deploy.sh
```

The script will:
- Build the Docker image locally
- Create a deployment package
- Copy the package to the server
- Deploy the application on the server

## Server Management

### View Logs
```bash
ssh root@2a01:4f9:3a:1288::203 "cd /opt/open-webui && docker-compose -f docker-compose.prod.yaml logs -f"
```

### Restart Service
```bash
ssh root@2a01:4f9:3a:1288::203 "cd /opt/open-webui && docker-compose -f docker-compose.prod.yaml restart"
```

### Backup Data
```bash
ssh root@2a01:4f9:3a:1288::203 "cd /opt/open-webui && docker run --rm -v open-webui-data:/data -v /opt/open-webui/backups:/backup alpine tar czf /backup/open-webui-backup-$(date +%Y%m%d).tar.gz -C /data ."
```

## Security Considerations

1. **Firewall Configuration**:
```bash
# Allow SSH and web ports
ufw allow 22/tcp
ufw allow 3000/tcp
ufw enable
```

2. **SSL/TLS Setup** (Recommended):
```bash
# Install Certbot
apt install certbot python3-certbot-nginx

# Get SSL certificate
certbot --nginx -d your-domain.com
```

3. **Regular Updates**:
```bash
# Update system
apt update && apt upgrade -y

# Update Docker images
docker-compose -f docker-compose.prod.yaml pull
docker-compose -f docker-compose.prod.yaml up -d
```

## Troubleshooting

1. **Check Container Status**:
```bash
docker ps
```

2. **View Container Logs**:
```bash
docker logs open-webui
```

3. **Check Resource Usage**:
```bash
docker stats
```

4. **Common Issues**:
- If the container fails to start, check the logs for error messages
- Ensure all required environment variables are set in .env
- Verify port 3000 is not in use by another service
- Check if the server has sufficient resources (CPU, RAM, storage)

## Maintenance

1. **Regular Backups**:
- Set up automated backups using cron jobs
- Store backups in a secure location
- Test backup restoration periodically

2. **Monitoring**:
- Set up monitoring for container health
- Monitor resource usage
- Set up alerts for critical issues

3. **Updates**:
- Regularly update the application
- Keep the system and Docker updated
- Review security patches

## Support

For additional support or issues:
1. Check the [Open WebUI Documentation](https://docs.openwebui.com/)
2. Visit the [GitHub Issues](https://github.com/open-webui/open-webui/issues)
3. Join the community Discord for help 