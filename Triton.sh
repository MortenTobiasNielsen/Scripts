#!/usr/bin/env bash
set -euo pipefail

# 1. System update
sudo apt update
sudo apt upgrade -y

# 2. Common prerequisites
sudo apt install -y build-essential cmake ninja-build \
                    python3-dev python3-pip python3-venv \
                    git wget gnupg ca-certificates software-properties-common

# 3. NVIDIA GPU & CUDA 12.8 setup

## 3.1 Install recommended NVIDIA driver
sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers autoinstall

## 3.2 Install CUDA GPG keyring (handles NO_PUBKEY errors)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

## 3.3 Add CUDA 12.8 APT repo and install
echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] \
https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" \
  | sudo tee /etc/apt/sources.list.d/cuda.list
sudo apt update
sudo apt install -y cuda-toolkit-12-8

# 4. AMD GPU & ROCm 6.3.4 setup

## 4.1 Download and install AMD GPU installer
wget https://repo.radeon.com/amdgpu-install/6.3.4/ubuntu/jammy/\
amdgpu-install_6.3.60304-1_all.deb
sudo apt install -y ./amdgpu-install_6.3.60304-1_all.deb

## 4.2 Install ROCm components (HIP, libraries, DKMS)
sudo amdgpu-install -y --usecase=rocm,hiplibsdk,dkms --rocmrelease=6.3.4

## 4.3 Add user to render & video groups for AMD access
sudo usermod -aG render,video $USER

# 5. Python virtual environment & Triton

python3 -m venv ~/triton-env
source ~/triton-env/bin/activate
pip install --upgrade pip
pip install triton

# 6. Environment variables (add to ~/.bashrc)

cat << 'EOF' >> ~/.bashrc

# — CUDA 12.8 —
export CUDA_HOME=/usr/local/cuda-12.8                                        :contentReference[oaicite:0]{index=0}
export PATH=\$CUDA_HOME/bin:\$PATH                                            :contentReference[oaicite:1]{index=1}
export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH                    :contentReference[oaicite:2]{index=2}

# — ROCm 6.3.4 —
export ROCM_PATH=/opt/rocm                                                     :contentReference[oaicite:3]{index=3}
export PATH=\$ROCM_PATH/bin:\$PATH                                              :contentReference[oaicite:4]{index=4}
export LD_LIBRARY_PATH=\$ROCM_PATH/lib:\$LD_LIBRARY_PATH                        :contentReference[oaicite:5]{index=5}
EOF

# 7. Reload shell to pick up env vars and verify
source ~/.bashrc

echo "✅ Installation complete. Reboot now to finalize GPU driver load."
