#!/usr/bin/env bash
set -e
export PATH=/usr/local/bin:$PATH
export LC_ALL=en_US.UTF-8

gcalcli --config-folder /home/ec2-user/.gcalcli --calendar Badminton import /tmp/badminton.ical

