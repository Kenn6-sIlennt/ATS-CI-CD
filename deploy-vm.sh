#!/bin/bash

# Deployment script untuk VM
# Dapat dijalankan manual atau dari GitHub Actions

set -e  # Exit on error

VM_USER="kenn"
VM_HOST="192.168.238.132"
VM_PASSWORD="matcha123"
APP_NAME="ats-flask-app"
CONTAINER_NAME="ats-web-flask"
PORT="5000"

echo "🚀 Starting deployment to VM: $VM_USER@$VM_HOST"
echo "=============================================="

# Function untuk menjalankan command di VM
run_on_vm() {
    local cmd="$1"
    sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "$cmd"
}

# 1. Cleanup existing container
echo "1. Cleaning up existing container..."
run_on_vm "docker rm -f $CONTAINER_NAME || true"
echo "✅ Cleanup completed"

# 2. Build Docker image
echo "2. Building Docker image..."
# Copy files to VM
echo "Copying files to VM..."
sshpass -p "$VM_PASSWORD" scp -r . "$VM_USER@$VM_HOST:/tmp/$APP_NAME"

# Build on VM
run_on_vm "
    cd /tmp/$APP_NAME && \
    echo 'Building Docker image...' && \
    docker build -t $APP_NAME:latest . && \
    echo '✅ Docker build completed'
"

# 3. Run container
echo "3. Starting container..."
run_on_vm "
    docker run -d \
        -p $PORT:$PORT \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        $APP_NAME:latest
"
echo "✅ Container started"

# 4. Wait for container to be ready
echo "4. Waiting for container to be ready..."
sleep 5

# 5. Health check
echo "5. Performing health check..."
for i in {1..5}; do
    if run_on_vm "curl -sSf http://localhost:$PORT/health"; then
        echo "✅ Health check PASSED!"
        break
    fi
    
    if [ $i -eq 5 ]; then
        echo "❌ Health check FAILED after 5 attempts"
        echo "Checking container logs..."
        run_on_vm "docker logs $CONTAINER_NAME"
        exit 1
    fi
    
    echo "Attempt $i/5 failed, retrying in 2 seconds..."
    sleep 2
done

# 6. Container status check
echo "6. Checking container status..."
run_on_vm "
    echo 'Container Status:'
    docker ps --filter \"name=$CONTAINER_NAME\"
    
    echo ''
    echo 'Container Details:'
    docker inspect $CONTAINER_NAME --format='{{json .State}}' | jq .
    
    echo ''
    echo 'Resource Usage:'
    docker stats $CONTAINER_NAME --no-stream
"

# 7. Cleanup temp files
echo "7. Cleaning up temporary files..."
run_on_vm "rm -rf /tmp/$APP_NAME"
echo "✅ Temporary files cleaned"

echo ""
echo "=============================================="
echo "🎉 Deployment Successful!"
echo "Application is running on: http://$VM_HOST:$PORT"
echo ""
echo "Quick commands:"
echo "  View logs:    ssh $VM_USER@$VM_HOST 'docker logs $CONTAINER_NAME'"
echo "  Stop app:     ssh $VM_USER@$VM_HOST 'docker stop $CONTAINER_NAME'"
echo "  Restart app:  ssh $VM_USER@$VM_HOST 'docker restart $CONTAINER_NAME'"
echo "  Check health: curl http://$VM_HOST:$PORT/health"
echo "=============================================="