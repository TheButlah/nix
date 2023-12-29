#!/usr/bin/env bash

apt-get update
apt-get install -y zsh git

adduser \
	--system \
	--shell $(which zsh) \
	--gecos 'Ryan Butler' \
	--group \
	--disabled-password \
	--home /home/ryan \
	ryan

usermod -a -G sudo ryan
echo "ryan ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/ryan

# Set up user account ssh
install --owner=ryan --group=ryan --mode=700 -d /home/ryan/.ssh
install --owner=ryan --group=ryan --mode=600 /root/.ssh/authorized_keys /home/ryan/.ssh/

# Disable root login and ssh passwords
rm /root/ssh/.authorized_keys
sed -i '/^PermitRootLogin /s/ .*/ no/' /etc/ssh/sshd_config
sed -i '/^PasswordAuthentication /s/ .*/ no/' /etc/ssh/sshd_config
systemctl restart sshd

# Install nix stuff
sudo -u ryan git clone https://github.com/TheButlah/nix /home/ryan/P/nix
sudo -u ryan /home/ryan/P/nix/user-setup.sh
