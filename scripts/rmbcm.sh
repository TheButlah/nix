#!/usr/bin/env bash

set -Eeuxo pipefail

sudo systemctl stop bluetooth.service
sudo rmmod hci_bcm4377
sudo modprobe hci_bcm4377
sudo systemctl start bluetooth.service
