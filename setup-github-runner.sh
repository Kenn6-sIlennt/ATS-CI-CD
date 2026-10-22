#!/bin/bash

# Script untuk setup GitHub Actions self-hosted runner di VM
# Jalankan di VM (192.168.238.132)

set -e

echo "========================================"
echo "GitHub Actions Runner Setup"
echo "========================================"

# 1. Prerequisites
echo "1. Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl wget docker.io docker-compose jq

# 2. Add user to docker group
echo "2. Adding user to docker group..."
sudo usermod -aG docker $USER
echo "⚠️  Please logout and login again for group changes to take effect"

# 3. Install GitHub Actions Runner
echo "3. Installing GitHub Actions Runner..."
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download latest runner
RUNNER_VERSION="2.324.0"
RUNNER_ARCH="x64"

curl -o actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

tar xzf ./actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

# 4. Configuration
echo "4. Runner configuration..."
echo ""
echo "========================================"
echo "⚠️  Manual Configuration Required"
echo "========================================"
echo ""
echo "Follow these steps:"
echo ""
echo "1. Go to your GitHub repository:"
echo "   https://github.com/Kenn6-sIlennt/ATS-CI-CD"
echo ""
echo "2. Navigate to:"
echo "   Settings → Actions → Runners"
echo ""
echo "3. Click 'New self-hosted runner'"
echo ""
echo "4. Select Linux and copy the commands"
echo ""
echo "5. Run the commands on this VM:"
echo "   - Configuration command"
echo "   - Run command"
echo ""
echo "Example commands (replace with your actual token):"
echo "----------------------------------------"
echo "./config.sh --url https://github.com/Kenn6-sIlennt/ATS-CI-CD --token YOUR_TOKEN"
echo "./run.sh"
echo "----------------------------------------"
echo ""
echo "6. For running as service:"
echo "sudo ./svc.sh install"
echo "sudo ./svc.sh start"
echo ""
echo "========================================"
echo "Setup complete for manual configuration"
echo "========================================"

# 5. Docker setup for self-hosted runner
echo "5. Configuring Docker for runner..."
echo "Creating docker-compose for runner..."

cat > docker-compose.runner.yml << 'EOF'
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-actions-runner
    environment:
      RUNNER_NAME: "vm-runner-${HOSTNAME}"
      RUNNER_WORKDIR: "/tmp/runner/work"
      ACCESS_TOKEN: "${ACCESS_TOKEN}"
      RUNNER_SCOPE: "repo"
      REPO_URL: "https://github.com/Kenn6-sIlennt/ATS-CI-CD"
      LABELS: "self-hosted,linux,vm"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-data:/data
    restart: unless-stopped

volumes:
  runner-data:
EOF

echo ""
echo "Docker compose file created at: docker-compose.runner.yml"
echo ""
echo "To run with Docker Compose:"
echo "1. Set ACCESS_TOKEN: export ACCESS_TOKEN=your_github_token"
echo "2. Start: docker-compose -f docker-compose.runner.yml up -d"
echo "3. Check logs: docker-compose -f docker-compose.runner.yml logs"

# 6. Test commands
echo ""
echo "6. Test commands for verification:"
echo "----------------------------------------"
echo "# Test Docker"
echo "docker --version"
echo "docker ps"
echo ""
echo "# Test Python"
echo "python3 --version"
echo ""
echo "# Test curl"
echo "curl --version"
echo ""
echo "# Test ports"
echo "netstat -tuln | grep :5000"
echo "----------------------------------------"

echo ""
echo "✅ Setup script completed"
echo "Next: Configure the runner manually using GitHub UI"