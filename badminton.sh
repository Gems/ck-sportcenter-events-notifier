#!/usr/bin/env bash
set -e
log="/var/log/badminton.log"
dir="$( cd "$( dirname "$(realpath ${BASH_SOURCE[0]})" )" >/dev/null 2>&1 && pwd )"
cd ${dir} >/dev/null

echo "$(date): Badminton started..." | tee -a ${log}

#./make-ical.sh 2>&1 | tee -a ${log}
./upload-ical.sh 2>&1 | tee -a ${log}

echo "Badminton's done\n\n" | tee -a ${log}

