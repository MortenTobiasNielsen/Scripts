#!/bin/sh

cd ~

# Uninstall possible docker installations
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; 
    do sudo apt-get remove $pkg; 
done

# Setup Docker apt repository
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update, upgrade, and install software 
sudo apt-get -y upgrade 
sudo apt-get install -y software-properties-common openssh-server docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Give access rights to the current user to Docker
sudo usermod -aG docker ${USER}

# Make sure that SSH is enabled and started
sudo systemctl enable ssh
sudo systemctl start ssh

# Setting overclocking and disabling bluetooth and wifi
printf "\nSetting overclocking, and disabling bluetooth and wifi.\n"
echo "
# Overclocking
arm_freq=2800
gpu_freq=900

# Disabling bluetooth and wifi
dtoverlay=disable-bt
dtoverlay=disable-wifi" | sudo tee -a /boot/firmware/config.txt >/dev/null

# Disable unused services
printf "\nDisable unused services.\n"
sudo systemctl disable bluetooth.service
sudo systemctl disable hciuart.service

# Creating keys for SSH
printf "\nCreating keys for SSH (private and public).\n"
mkdir .ssh
chmod 700 .ssh
cd .ssh
ssh-keygen -t rsa -b 4096 -f rpi_key -q -N ""
cat rpi_key.pub >> authorized_keys
printf "\nKeys created and added to authorized_keys. The files can be found here ~/.ssh\n"

# Disable password access
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
printf "\Password authentication has been disabled. Remember to copy rpi_key onto the computer which should be able to access this device and thereafter run shutdown -r now\n"