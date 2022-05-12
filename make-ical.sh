#!/usr/bin/env bash
#set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $dir

export ICAL_SCHEDULE=/tmp/schedule.ical

# Prepare ICAL template
cat >${ICAL_SCHEDULE} <<EOF
BEGIN:VCALENDAR
VERSION:2.0
PROID:-//Gems//Kockelshoer Fetcher 0.1/EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
EOF

export PATH=/usr/local/bin:$PATH  
export LC_ALL=en_US.UTF-8
export TZ=CET

function gcal() {
  gcalcli --config-folder ${GCALCLI_CONFIG} --nocolor --calendar Badminton $@
}

function get-uid() {
  echo "${1}" | md5sum | tr '[:lower:]' '[:upper:]' | awk '{print substr($1,1,8) "-" substr($1,9,4) "-" substr($1,13,4) "-" substr($1,17,4) "-" substr($1,21)}'
}

function get-datetime() {
  local d=`echo ${1} | awk -F . '{print $1}'`
  local m=`echo ${1} | awk -F . '{print $2}'`
  local y=`echo ${1} | awk -F . '{print $3}'`
  local hh=`echo ${2} | awk -F : '{print $1}'`
  local mm=`echo ${2} | awk -F : '{print $2}'`
  local ss=`echo ${2} | awk -F : '{print $3}'`

  local date=`date -d "${hh}:${mm}:${ss:-00} ${y}-${m}-${d}"`
  date -u -d "${date} ${4}" ${3}
}

function compose-icalevent() {
  while IFS='%' read -r title date time desc; do
    local uid=`get-uid "event-${date}-${time}-${title}"`
    local start_date=`get-datetime ${date} ${time} +%Y%m%dT%H%M%SZ`
    local end_date=`get-datetime ${date} ${time} +%Y%m%dT%H%M%SZ '+1 hour'`
    local description=`./namer.py ${uid}`

    local curr_date=`date -u +%s`
    local event_date=`get-datetime ${date} ${time} +%s`

    if [ $curr_date -ge $event_date ]; then
      continue
    fi

    local event=`gcal search "${description}" | grep -vE '^$' | grep -vFi 'No events'`

    if [ -n "${event}" ]; then
      local found_date=`date -d "$(echo "${event}" | awk '{print $1 " " $2}')" +%s`
      local found_title="${event:21}"
    
      if [ $found_date -eq $event_date ] && [ "${title}" = "${found_title}" ]; then
        continue
      fi
    fi

    printf "\
BEGIN:VEVENT\n\
SUMMARY:${title}\n\
DESCRIPTION:${description}\n\
UID:${uid}\n\
SEQUENCE:0\n\
DTSTART:${start_date}\n\
DTEND:${end_date}\n\
`cat ical.tmpl`
LOCATION: 20 Route de Bettembourg, 1899 Kockelscheuer\n\
GEO:49.5626814;6.1082521\n\
CLASS:CONFIDENTIAL\n\
STATUS:NEEDS-ACTION\n\
CATEGORIES:SPORT,PERSONAL\n\
END:VEVENT\n"
 
  done <&0
}

cat ${SCHEDULE_JSON} | jq --raw-output '.[] | "\(.title)%\(.date)%\(.start)%\(.description)"' | grep -vE '^null' | compose-icalevent >>${ICAL_SCHEDULE}

cat >>${ICAL_SCHEDULE} <<__EOF
END:VCALENDAR
__EOF

echo "Make ICAL: done"

