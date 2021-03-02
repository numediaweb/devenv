#!/usr/bin/env bash
set -e
echo "enabling 1Gb swap.."
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1024 count=1048576
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1
sudo chmod 600 /var/swap.1
