#!/usr/bin/env bash
set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $dir

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

function log() {
  echo "$@" >&2
}

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
  local need_new_line=0

  while IFS='%' read -r title date time duration; do
    local uid=`get-uid "event-${date}-${time}-${title}-${duration}"`
    local start_date=`get-datetime ${date} ${time} +%Y%m%dT%H%M%SZ`
    local end_date=`get-datetime ${date} ${time} +%Y%m%dT%H%M%SZ "+${duration} hour"`
    local description=`./namer.py ${uid}`

    local curr_date=`date -u +%s`
    local event_date=`get-datetime ${date} ${time} +%s`

    if [ $curr_date -ge $event_date ]; then
      log -n "."
      need_new_line=1
      continue
    fi

    if [ ${need_new_line} -eq 1 ]; then
      log -e ""
      need_new_line=0
    fi

    log -n "Looking if event '${description} is already registered... "
    local event=`gcal search "${description}" | grep -vE '^$' | grep -vFi 'No events'`

    if [ -n "${event}" ]; then
      local found_date=`date -d "$(echo "${event}" | awk '{print $1 " " $2}')" +%s`
      local found_title="${event:21}"
    
      if [ $found_date -eq $event_date ] && [ "${title}" = "${found_title}" ]; then
        log "Found date is the same, skipped."
        continue
      fi
    fi

    log "Not registered, creating ICAL entry."

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

# We assume that if there are many reservations for a single court on a single date, the reservations are consecutive.
#So we treat the number of reservations of a single court as the total reservation duration in hours for the court on the given day.

cat ${SCHEDULE_JSON} \
  | jq --raw-output -s '.[] | group_by(.date)[] | group_by(.title)[] | "\(.[0].title)%\(.[0].date)%\(min_by(.start).start)%\(length|tostring)"' \
  | grep -vE '^null' \
  | compose-icalevent >>${ICAL_SCHEDULE}

cat >>${ICAL_SCHEDULE} <<__EOF
END:VCALENDAR
__EOF

log "Make ICAL: done"

