#!/bin/bash
# Alumni System Deployment Script
# ไฟล์: alumni-deploy/deploy.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="alumni"
COMPOSE_FILE="docker-compose.prod.yml"
SERVER_IP="49.231.145.165"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    print_status "Checking Docker status..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if .env file exists
check_env() {
    print_status "Checking environment configuration..."
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Creating from template..."
        cp .env.example .env
        print_warning "Please edit .env file with your production values before continuing."
        print_warning "Run: nano .env"
        exit 1
    fi
    print_success "Environment file found"
}

# Function to login to GitHub Container Registry
login_ghcr() {
    print_status "Logging into GitHub Container Registry..."
    
    if [ -z "$GITHUB_TOKEN" ]; then
        print_warning "GITHUB_TOKEN not set. Attempting to use existing login..."
    else
        echo $GITHUB_TOKEN | docker login ghcr.io -u phm-oh --password-stdin
        print_success "Logged into GHCR"
    fi
}

# Function to pull latest images
pull_images() {
    print_status "Pulling latest images..."
    docker-compose -f $COMPOSE_FILE pull
    print_success "Images pulled successfully"
}

# Function to stop existing containers
stop_containers() {
    print_status "Stopping existing containers..."
    docker-compose -f $COMPOSE_FILE down --remove-orphans
    print_success "Containers stopped"
}

# Function to start containers
start_containers() {
    print_status "Starting Alumni containers..."
    docker-compose -f $COMPOSE_FILE up -d
    print_success "Containers started"
}

# Function to check container health
check_health() {
    print_status "Checking container health..."
    
    # Wait for containers to start
    sleep 30
    
    # Check backend health
    print_status "Checking backend health..."
    if curl -f http://localhost:5500/api/health > /dev/null 2>&1; then
        print_success "Backend is healthy"
    else
        print_error "Backend health check failed"
        return 1
    fi
    
    # Check nginx (main entry point)
    print_status "Checking nginx proxy health..."
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        print_success "Nginx proxy is healthy"
    else
        print_error "Nginx proxy health check failed"
        return 1
    fi
    
    # Check API through nginx
    print_status "Checking API through nginx..."
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "API proxy is working"
    else
        print_warning "API proxy may have issues"
    fi
}

# Function to show container status
show_status() {
    print_status "Container status:"
    docker-compose -f $COMPOSE_FILE ps
    
    print_status "🌐 Access URLs:"
    echo "📱 Frontend (via Nginx): http://$SERVER_IP:3000"
    echo "🔧 Backend API:          http://$SERVER_IP:5500/api"
    echo "🔄 API Proxy:            http://$SERVER_IP:3000/api"
    echo "🏠 Domain:               https://alumni.udvc.ac.th (when DNS configured)"
    echo ""
    echo "✅ Users should access: http://$SERVER_IP:3000"
}

# Function to show logs
show_logs() {
    print_status "Showing recent logs..."
    docker-compose -f $COMPOSE_FILE logs --tail=50
}

# Function to cleanup old images
cleanup() {
    print_status "Cleaning up old images..."
    docker image prune -f
    docker volume prune -f
    print_success "Cleanup completed"
}

# Function to backup (placeholder)
backup() {
    print_status "Creating backup..."
    BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup .env
    cp .env $BACKUP_DIR/
    
    # Backup docker volumes (if any data to backup)
    print_success "Backup created in $BACKUP_DIR"
}

# Main deployment function
deploy() {
    print_status "🚀 Starting Alumni System Deployment..."
    
    check_docker
    check_env
    login_ghcr
    backup
    pull_images
    stop_containers
    start_containers
    
    if check_health; then
        print_success "🎉 Alumni System deployed successfully!"
        show_status
    else
        print_error "❌ Deployment failed - health checks failed"
        print_status "Showing logs for debugging:"
        show_logs
        exit 1
    fi
}

# Script usage
usage() {
    echo "Alumni Deployment Script"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy     - Full deployment (default)"
    echo "  start      - Start containers"
    echo "  stop       - Stop containers"
    echo "  restart    - Restart containers"
    echo "  status     - Show container status"
    echo "  logs       - Show container logs"
    echo "  pull       - Pull latest images"
    echo "  cleanup    - Remove old images"
    echo "  backup     - Create backup"
    echo "  health     - Check container health"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh deploy"
    echo "  ./deploy.sh status"
    echo "  ./deploy.sh logs"
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    start)
        check_docker
        start_containers
        ;;
    stop)
        check_docker
        stop_containers
        ;;
    restart)
        check_docker
        stop_containers
        start_containers
        check_health
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    pull)
        check_docker
        login_ghcr
        pull_images
        ;;
    cleanup)
        cleanup
        ;;
    backup)
        backup
        ;;
    health)
        check_health
        ;;
    *)
        usage
        exit 1
        ;;
esac