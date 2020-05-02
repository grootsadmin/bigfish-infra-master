#!/bin/bash

set -ex

# update
apt-get update

export DEBIAN_FRONTEND=noninteractive
apt-get -y upgrade

echo "Copy instance id "
curl http://169.254.169.254/latest/meta-data/instance-id > /var/tmp/aws-mon/instance-id

echo "Copy availability zone of the instance"
curl http://169.254.169.254/latest/meta-data/placement/availability-zone > /var/tmp/aws-mon/placement/availability-zone

echo "Restarting cloudwatch agent"
sudo systemctl restart amazon-cloudwatch-agent.service
