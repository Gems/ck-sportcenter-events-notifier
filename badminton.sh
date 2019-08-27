#!/usr/bin/env bash
set -e
log="/var/log/badminton.log"

echo "$(date): Badminton started..." | tee -a ${log}

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${dir} >/dev/null

./make-ical.sh 2>&1 | tee -a ${log}

export LC_ALL=en_US.UTF-8
gcalcli --calendar Badminton import /tmp/badminton.ical 2>&1 | tee -a ${log}

echo "Badminton's done" | tee -a ${log}

