#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
sudo systemctl enable ssh
sudo systemctl start ssh
sudo apt-get install -y software-properties-common openssh-server fail2ban 

# Setting overclocking and disabling bluetooth and wifi
echo "
# Overclocking
arm_freq=2800
gpu_freq=900

# Disabling bluetooth and wifi
dtoverlay=disable-bt
dtoverlay=disable-wifi" | sudo tee -a /boot/firmware/config.txt

# Disable unused services
sudo systemctl disable bluetooth.service
sudo systemctl disable hciuart.service

# Setup fail2ban
sudo sed -i "s|^backend = auto$|backend = systemd|" /etc/fail2ban/jail.conf # It might be possible to remove this with version 1.1.0-4 of debian
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Creating keys for SSH
echo "Creating keys for SSH (private and public)."
cd ~
mkdir .ssh
chmod 700 .ssh
cd .ssh
ssh-keygen -t rsa -b 4096 -f rpi_key -q -N ""
cat rpi_key.pub >> authorized_keys
echo "shh keys created and added to authorized_keys. The files can be found here ~/.ssh"

# Disable password access
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "Password authentication has been disabled. Remember to copy rpi_key onto the computer which should be able to access this device and thereafter run shutdown -r now"