#!/usr/bin/env bash
set -eu -o pipefail

# TODO: deprecate or update this bin/init.sh in favor of using the same setup
# that Vagrant and Terraform does.

# Run as root to set up a new ubuntu 20.04 server
# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04

apt-get --yes update
apt-get --yes upgrade

# Support for bin/iptables-setup-firewall.sh
apt-get --yes install netfilter-persistent iptables-persistent

./bin/iptables-setup-firewall.sh

# TODO: ufw is no longer used in favor of using iptables directly.
#ufw allow ssh
#
## Limit multiple ssh connection attempts
#ufw limit ssh/tcp
#
#ufw allow 80/tcp
#ufw allow 443/tcp
#ufw show added
#ufw enable


## Create the dev user
adduser dev || echo 'dev user exists already?'

# Set the user to have sudo privileges by placing in the sudo group
usermod -aG sudo dev

# Add your public key (id_rsa.pub)
su --command "mkdir ~/.ssh && chmod 700 ~/.ssh" dev
su --command "read -p \"Paste in your .ssh/id_rsa.pub key: \" PUBLICKEY && echo \$PUBLICKEY > ~/.ssh/authorized_keys" dev
su --command "chmod 600 ~/.ssh/authorized_keys" dev

# Disable password authentication for ssh and only use public keys
sed --in-place "s/^PasswordAuthentication yes$/PasswordAuthentication no/" /etc/ssh/sshd_config
sed --in-place "s/^#PasswordAuthentication yes$/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl reload sshd

# Set the external-puzzle-massive for internal use. Which makes much sense.
echo "127.0.0.1 external-puzzle-massive" >> /etc/hosts
