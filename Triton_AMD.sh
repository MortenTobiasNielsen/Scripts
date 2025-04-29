#!/usr/bin/env bash
set -euo pipefail

# 1. System update
sudo apt update
sudo apt upgrade -y

# 2. Common prerequisites
sudo apt install -y build-essential cmake ninja-build \
                    python3-dev python3-pip python3-venv \
                    git wget gnupg ca-certificates software-properties-common

# 3. AMD GPU & ROCm 6.3.4 setup

## 3.1 Download and install AMD GPU installer
wget https://repo.radeon.com/amdgpu-install/6.3.4/ubuntu/jammy/\
amdgpu-install_6.3.60304-1_all.deb
sudo apt install -y ./amdgpu-install_6.3.60304-1_all.deb

## 3.2 Install ROCm components (HIP, libraries, DKMS)
sudo amdgpu-install -y --usecase=rocm,hiplibsdk,dkms --rocmrelease=6.3.4

## 3.3 Add user to render & video groups for AMD access
sudo usermod -aG render,video $USER

# 4. Python virtual environment & Triton

python3 -m venv ~/triton-env
source ~/triton-env/bin/activate
pip install --upgrade pip
pip install triton

# 5. Environment variables (add to ~/.bashrc)

cat << 'EOF' >> ~/.bashrc

# — ROCm 6.3.4 —
export ROCM_PATH=/opt/rocm
export PATH=\$ROCM_PATH/bin:\$PATH
export LD_LIBRARY_PATH=\$ROCM_PATH/lib:\$LD_LIBRARY_PATH
EOF

# 6. Reload shell to pick up env vars and verify
source ~/.bashrc

echo "✅ Installation complete. Reboot now to finalize GPU driver load."
