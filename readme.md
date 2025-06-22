# 🎓 Alumni System Deployment

Complete deployment configuration for the Alumni Registration System.

## 📋 System Overview

- **Frontend**: React 19 + Vite 6 with nginx
- **Backend**: Node.js 20 + Express + MongoDB
- **Database**: MongoDB Atlas (cloud)
- **File Storage**: Cloudinary
- **Container Registry**: GitHub Container Registry (GHCR)
- **Server**: 49.231.145.165

## 🎯 Service Ports

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| Frontend | 3000 | http://49.231.145.165:3000 | Alumni frontend (React) |
| Backend | 5000 | http://49.231.145.165:5000 | Alumni API server |
| Nginx | 8080 | http://49.231.145.165:8080 | Reverse proxy (optional) |
| Domain | 80/443 | https://alumni.udvc.ac.th | Production domain |

## 🚀 Quick Start

### 1. Prerequisites

```bash
# Install Docker & Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Reboot or logout/login to apply docker group
```

### 2. Clone & Setup

```bash
# Clone this repository
git clone <alumni-deploy-repo-url>
cd alumni-deploy

# Create environment file
cp .env.example .env
nano .env  # Edit with your production values

# Make deploy script executable
chmod +x deploy.sh
```

### 3. Deploy

```bash
# Full deployment
./deploy.sh deploy

# Or step by step
./deploy.sh pull    # Pull latest images
./deploy.sh start   # Start containers
./deploy.sh health  # Check health
```

## 📁 Project Structure

```
alumni-deploy/
├── docker-compose.prod.yml    # Container orchestration
├── nginx.conf                 # Reverse proxy configuration
├── .env.example              # Environment template
├── .env                      # Production environment (create this)
├── deploy.sh                 # Deployment script
├── ssl/                      # SSL certificates (if using Let's Encrypt)
├── backups/                  # Backup storage
└── README.md                 # This file
```

## ⚙️ Configuration

### Environment Variables (.env)

Key variables to configure:

```bash
# Server
SERVER_IP=49.231.145.165
NODE_ENV=production

# Database
MONGODB_URI="mongodb+srv://..."

# Authentication
JWT_SECRET="your-jwt-secret"

# Email
EMAIL_USER=alumni2@it.udvc.ac.th
EMAIL_PASS=your-app-password

# Cloudinary
CLOUDINARY_CLOUD_NAME=djnhoz1vm
CLOUDINARY_API_KEY=695137725626495
CLOUDINARY_API_SECRET=your-secret

# CORS
CLIENT_URL=https://alumni.udvc.ac.th,http://49.231.145.165:3000
FRONTEND_URL=https://alumni.udvc.ac.th
```

### Docker Images

The system uses these pre-built images:

- **Frontend**: `ghcr.io/phm-oh/fontend-alumni:latest`
- **Backend**: `ghcr.io/phm-oh/alumni-registration-system:latest`

Images are automatically built via GitHub Actions when code is pushed to:
- Frontend repo: `phm-oh/fontend-alumni`
- Backend repo: `phm-oh/alumni-registration-system`

## 🔧 Management Commands

### Deployment Script

```bash
# Full deployment
./deploy.sh deploy

# Container management
./deploy.sh start      # Start containers
./deploy.sh stop       # Stop containers
./deploy.sh restart    # Restart containers
./deploy.sh status     # Show status

# Maintenance
./deploy.sh pull       # Pull latest images
./deploy.sh logs       # Show logs
./deploy.sh health     # Health check
./deploy.sh cleanup    # Remove old images
./deploy.sh backup     # Create backup
```

### Manual Docker Commands

```bash
# Pull latest images
docker-compose -f docker-compose.prod.yml pull

# Start services
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop services
docker-compose -f docker-compose.prod.yml down

# View running containers
docker-compose -f docker-compose.prod.yml ps
```

## 🌐 Domain Setup (alumni.udvc.ac.th)

### Option 1: Cloudflare (Recommended)

1. **Add DNS Record in Cloudflare**:
   ```
   Type: A
   Name: alumni
   Content: 49.231.145.165
   Proxy: ✅ Enabled (Orange Cloud)
   ```

2. **SSL Configuration**:
   - SSL/TLS → Overview → **Full (strict)**
   - SSL/TLS → Edge Certificates → **Always Use HTTPS: ON**

3. **Update nginx.conf** (already configured for Cloudflare)

### Option 2: Let's Encrypt

```bash
# Install certbot
sudo apt install certbot

# Generate certificate
sudo certbot certonly --standalone -d alumni.udvc.ac.th

# Add to nginx.conf
# ssl_certificate /etc/letsencrypt/live/alumni.udvc.ac.th/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/alumni.udvc.ac.th/privkey.pem;
```

## 📊 Monitoring & Health Checks

### Health Endpoints

- **Backend**: http://49.231.145.165:5000/api/health
- **Frontend**: http://49.231.145.165:3000/health
- **Nginx**: http://49.231.145.165:8080/health

### Container Health

```bash
# Check container health
docker-compose -f docker-compose.prod.yml ps

# View detailed container info
docker inspect alumni-backend
docker inspect alumni-frontend

# Monitor resource usage
docker stats alumni-backend alumni-frontend
```

### Logs

```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f alumni-backend
docker-compose -f docker-compose.prod.yml logs -f alumni-frontend

# Nginx logs (if using container)
docker-compose -f docker-compose.prod.yml logs -f alumni-nginx
```

## 🔄 Update Process

### Automatic Updates (via GitHub Actions)

When code is pushed to the repositories, GitHub Actions will:
1. Build new Docker images
2. Push to GHCR
3. SSH to server and deploy automatically

### Manual Updates

```bash
# Pull latest images
./deploy.sh pull

# Restart with new images
./deploy.sh restart

# Check health
./deploy.sh health
```

## 🐛 Troubleshooting

### Common Issues

**Container fails to start:**
```bash
# Check logs
./deploy.sh logs

# Check environment
cat .env

# Restart specific service
docker-compose -f docker-compose.prod.yml restart alumni-backend
```

**Health check fails:**
```bash
# Test endpoints manually
curl http://localhost:5000/api/health
curl http://localhost:3000/health

# Check container status
docker-compose -f docker-compose.prod.yml ps
```

**Port conflicts:**
```bash
# Check what's using ports
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :5000

# Kill conflicting processes
sudo fuser -k 3000/tcp
sudo fuser -k 5000/tcp
```

### Database Connection Issues

```bash
# Test MongoDB connection
docker-compose -f docker-compose.prod.yml exec alumni-backend node -e "
const mongoose = require('mongoose');
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB error:', err));
"
```

## 📞 Support

### Maintenance Schedule

- **Daily**: Automatic log rotation
- **Weekly**: Container health checks
- **Monthly**: Image updates, backup verification

### Contact

For deployment issues:
1. Check logs: `./deploy.sh logs`
2. Check status: `./deploy.sh status`
3. Create GitHub issue in respective repositories

## 🔒 Security Notes

- All sensitive data is in `.env` (not committed to git)
- Containers run with minimal privileges
- Database is hosted on MongoDB Atlas (encrypted)
- SSL termination via Cloudflare or Let's Encrypt
- Rate limiting configured in nginx
- CORS configured for specific domains

## 📈 Performance

### Recommended Server Specs

- **CPU**: 2+ cores
- **RAM**: 4GB+ 
- **Disk**: 20GB+ SSD
- **Network**: 100Mbps+

### Optimization

- Images are multi-architecture (amd64/arm64)
- Frontend uses gzip compression
- Static files cached for 1 year
- Database connection pooling
- Container health checks prevent traffic to unhealthy instances