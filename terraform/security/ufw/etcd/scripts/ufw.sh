#!/bin/bash
set -e

sudo apt-get clean -yqq
sudo apt-get update -yqq
sudo apt-get install -yqq \
    ufw

sudo ufw --force reset

# Allow TCP forwarding
sudo sed -i -r 's|^#(net/ipv4/ip_forward).*|\1=1|g' /etc/ufw/sysctl.conf
sudo sed -i -r 's|^#(net/ipv6/conf/default/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf
sudo sed -i -r 's|^#(net/ipv6/conf/all/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf

sudo ufw default allow FORWARD

# Drop All connection after processing all intermediate rules
sudo sed -i -r 's|^COMMIT|-A ufw-reject-input -j DROP\nCOMMIT|g' /etc/ufw/after.rules

# Allow VPN
sudo ufw allow in on ${private_interface} to any port ${vpn_port} # vpn on private interface
sudo ufw allow in on ${vpn_interface}

# Disable Logging
sudo ufw logging off

# Allow SSH
sudo ufw allow ssh

# Allow Saltstack
# sudo ufw allow salt

# Allow Etcd
# sudo ufw allow etcd

# Deny Incoming connection by default
sudo ufw default deny incoming