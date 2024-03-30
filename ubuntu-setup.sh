#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o errtrace  # pass ERR trap down to functions, substitutions, etc
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if [[ "${USER}" != "root" ]]; then
	echo "Expected root user."
	exit 1
fi

if [[ "$#" -ne 2 ]]; then
	echo "Must pass username to create, followed by authorized_keys path, as arguments"
	exit 1
fi

NEW_USER="${1}"
KEYPATH="${2}"

if [ $(getent passwd ${NEW_USER}) ]; then
	echo "user ${NEW_USER} already exists!"
	exit 1
fi

if ! [ -f "${KEYPATH}" ]; then
	echo "keypath "${KEYPATH}" does not exist!"
	exit 1
fi

if ! [ $(getent group docker) ]; then
	groupadd docker
fi

apt-get update
apt-get install -y zsh git

adduser \
	--shell $(which zsh) \
	--gecos "${NEW_USER}" \
	--disabled-password \
	${NEW_USER}

usermod -a -G sudo,docker ${NEW_USER}
echo "${NEW_USER} ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/${NEW_USER}

# Set up user account ssh
install --owner=${NEW_USER} --group=${NEW_USER} --mode=700 -d /home/${NEW_USER}/.ssh
install --owner=${NEW_USER} --group=${NEW_USER} --mode=600 $KEYPATH /home/${NEW_USER}/.ssh/

# Disable root login and ssh passwords
rm $KEYPATH
sed -i '/^PermitRootLogin /s/ .*/ no/' /etc/ssh/sshd_config || true
sed -i '/^PasswordAuthentication /s/ .*/ no/' /etc/ssh/sshd_config || true
systemctl restart sshd

# Install nix stuff
sudo -u ${NEW_USER} git clone https://github.com/TheButlah/nix /home/${NEW_USER}/P/nix
sudo -u ${NEW_USER} /home/${NEW_USER}/P/nix/user-setup.sh
