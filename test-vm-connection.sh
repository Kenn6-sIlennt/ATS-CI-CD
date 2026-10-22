#!/bin/bash

# Script untuk testing koneksi ke VM server
# Digunakan untuk troubleshooting pipeline deployment

VM_USER="kenn"
VM_HOST="192.168.238.132"
VM_PASSWORD="matcha123"

echo "======================================"
echo "Testing VM Connection for ATS-CI-CD"
echo "======================================"
echo "Target: $VM_USER@$VM_HOST"
echo ""

# Test 1: SSH Connection
echo "1. Testing SSH Connection..."
if sshpass -p "$VM_PASSWORD" ssh -o ConnectTimeout=5 "$VM_USER@$VM_HOST" "echo 'SSH Connection Successful'"; then
    echo "✅ SSH Connection: PASSED"
else
    echo "❌ SSH Connection: FAILED"
    echo "   Check:"
    echo "   - Is VM running?"
    echo "   - Are credentials correct?"
    echo "   - Is SSH service running on VM?"
fi

echo ""

# Test 2: Docker Availability
echo "2. Testing Docker on VM..."
if sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "docker --version"; then
    echo "✅ Docker: INSTALLED"
    
    # Check Docker daemon
    if sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "docker ps"; then
        echo "✅ Docker Daemon: RUNNING"
    else
        echo "⚠️  Docker Daemon: NOT RUNNING or permission issue"
    fi
else
    echo "❌ Docker: NOT INSTALLED"
    echo "   Install Docker on VM:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "   sudo sh get-docker.sh"
fi

echo ""

# Test 3: Port Availability
echo "3. Testing Port 5000..."
if sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "netstat -tuln | grep :5000"; then
    echo "⚠️  Port 5000: IN USE"
    echo "   Check if container is already running"
else
    echo "✅ Port 5000: AVAILABLE"
fi

echo ""

# Test 4: Disk Space
echo "4. Checking Disk Space..."
sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "df -h /"

echo ""

# Test 5: Python Availability
echo "5. Checking Python Version..."
if sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "python3 --version"; then
    echo "✅ Python: INSTALLED"
else
    echo "❌ Python: NOT FOUND"
fi

echo ""

# Test 6: Directory Permissions
echo "6. Checking /tmp permissions..."
sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "ls -la /tmp | head -5"

echo ""
echo "======================================"
echo "Summary:"
echo "======================================"

# Create summary
if sshpass -p "$VM_PASSWORD" ssh -o ConnectTimeout=5 "$VM_USER@$VM_HOST" "echo 'connected'" &>/dev/null; then
    echo "✅ VM is reachable"
    
    if sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "docker --version" &>/dev/null; then
        echo "✅ Docker is installed"
    else
        echo "❌ Docker is NOT installed"
    fi
    
    if sshpass -p "$VM_PASSWORD" ssh "$VM_USER@$VM_HOST" "python3 --version" &>/dev/null; then
        echo "✅ Python is installed"
    else
        echo "⚠️  Python may not be installed"
    fi
    
    echo ""
    echo "Next steps:"
    echo "1. Install Docker if missing"
    echo "2. Start Docker service if not running"
    echo "3. Add user to docker group: sudo usermod -aG docker $VM_USER"
    echo "4. Logout and login again for group changes"
else
    echo "❌ VM is NOT reachable"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check VM power status"
    echo "2. Verify IP address: $VM_HOST"
    echo "3. Check network connectivity"
    echo "4. Verify SSH credentials"
fi

echo "======================================"