#!/usr/bin/env bash
set -euo pipefail

# 1. Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# 2. Install NVIDIA drivers (auto-detect recommended driver)
sudo apt install -y ubuntu-drivers-common                      # Cherry Servers guide :contentReference[oaicite:0]{index=0}
sudo ubuntu-drivers autoinstall

# 3. Add CUDA 12.x repository and install CUDA toolkit
sudo apt install -y wget gnupg ca-certificates
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/7fa2af80.pub
echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" \
     | sudo tee /etc/apt/sources.list.d/cuda.list
sudo apt update
sudo apt install -y cuda-12-1                                  # NVIDIA CUDA guide :contentReference[oaicite:1]{index=1}

# 4. Install development tools and Python
sudo apt install -y build-essential cmake ninja-build \
                    python3-dev python3-pip python3-venv git   # Triton source deps :contentReference[oaicite:2]{index=2}

# 5. Set up Python virtual environment
python3 -m venv ~/triton-env
source ~/triton-env/bin/activate
pip install --upgrade pip

# 6. Install Triton compiler
pip install triton                                           # Official Triton PyPI :contentReference[oaicite:3]{index=3}

# 7. Verify Triton installation
python3 - <<EOF
import triton
print("Triton version:", triton.__version__)
EOF

echo "✅ Triton development environment setup complete!"
