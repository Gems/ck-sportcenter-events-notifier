#!/usr/bin/env bash

service cron start
echo "Welcome to Badminton Organizer v0.1" | tee -a /var/log/badminton.log

sleep infinity

