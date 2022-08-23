#!/usr/bin/env bash

echo "Telegram bot token: $TELEGRAM_BOT_TOKEN"
echo "Telegram chat id: $TELEGRAM_CHAT_ID"

if [ -z "$TELEGRAM_BOT_TOKEN" -o -z "$TELEGRAM_CHAT_ID" ]; then
  echo "Could not send a notification for the call for RSVP. Telegram token or/and chat aren't configured." >&2
  exit 0
fi

function send_message
{
  local MESSAGE="{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"$1\"}"
  #echo "message payload: ${MESSAGE}"
  
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" -H "Content-Type: application/json" -d "${MESSAGE}" 
}

function send_sticker
{
  local PAYLOAD="{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"sticker\": \"$1\"}"
  #echo "Sticker payload: ${PAYLOAD}"

  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendSticker" -H "Content-Type: application/json" -d "${PAYLOAD}" 
}

function get_random_sticker
{
  local RANDOM=$$$(date +%s)
  
  local strickers_when_reservations_exist=()
  strickers_when_reservations_exist[0]="CAACAgIAAxkBAAEDszJh5Tvt1CeaW6JUfsehS_OozIZhYAACvAUAAj-VzAoTSKpoG9FPRiME"
  strickers_when_reservations_exist[1]="CAACAgIAAxkBAAEEo5didO6cilp1FuBqu5BSJ74cRPXQyAACvAUAAj-VzAoTSKpoG9FPRiQE"
  strickers_when_reservations_exist[2]="CAACAgIAAxkBAAEEo51idO6zL0QoqDjr_ZfxF17D4d1iSwACvgUAAj-VzAqbjwKIXUsHLSQE"
  strickers_when_reservations_exist[3]="CAACAgIAAxkBAAEEo5tidO6piwZV4toxrobcQ_DtMrJK9AAC0wUAAj-VzAqfWrvSXUfHMSQE"
  strickers_when_reservations_exist[4]="CAACAgIAAxkBAAEEo5lidO6f0b-kxV9EF4lCwuxS7WK-3gAC3QUAAj-VzApJ56lEsLkRFSQE"

  local strickers_when_no_reservations=()
  strickers_when_no_reservations[0]="CAACAgIAAxkBAAEEozlidMUCwS_lpQ_UIQRs_j3dkvaNNgACugUAAj-VzArb-JYvDlr2bCQE"
  strickers_when_no_reservations[1]="CAACAgIAAxkBAAEEo49idO5Xu-7Is-Xe4GJhCNxYSMvWAAPUBQACP5XMCly3ov1JATo-JAQ"
  strickers_when_no_reservations[2]="CAACAgIAAxkBAAEEo5FidO5j1CCGIYnYYVxvMY5w_oYZDAACvwUAAj-VzAr5wuwdpEkoEyQE"
  strickers_when_no_reservations[3]="CAACAgIAAxkBAAEEo6VidO_41RwiFiZZMNqoh1jl3CIQhgAC3gUAAj-VzApvED_5xd0MFyQE"

  if [ -z $1 ]
  then
    echo ${strickers_when_reservations_exist[$RANDOM % ${#strickers_when_reservations_exist[@]}]}
  else
    echo ${strickers_when_no_reservations[$RANDOM % ${#strickers_when_no_reservations[@]}]}
  fi
}

function send_poll
{
  local is_anonymous="$1"
  shift
  local allow_multiple_answers="$1"
  shift
  local question="$1"
  shift

  local delim=""
  local answers=""

  for x in "$@"; do
    #echo "$x";
    answers="${answers}${delim}\"${x}\""
    delim=", "
  done
  
  local PAYLOAD="{\"chat_id\": \"${TELEGRAM_CHAT_ID}\", \"question\": \"${question}\", \"is_anonymous\": \"${is_anonymous}\", \"allows_multiple_answers\":\"${allow_multiple_answers}\", \"options\": [${answers}]}"
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPoll" -H "Content-Type: application/json" -d "${PAYLOAD}" 

  #echo "Poll payload: ${PAYLOAD}"
}

function get_reservations_string
{
  local today_day_of_week=$(date +%a)
  if [ "${today_day_of_week}" == "Sun" ]; then
    local week_start_date=$(date -d "next-monday" +%d.%m.%Y) # next Monday
    local week_end_date=$(date -d "next-sunday" +%d.%m.%Y) # next Sunday
  else
    local week_start_date=$(date -d "last-sunday +1 day" +%d.%m.%Y) # current/last Monday
    local week_end_date=$(date -d "next-sunday" +%d.%m.%Y) # next Sunday
  fi

  local LATER_THAN_WEEK_START_FILTER='(.date | strptime("%d.%m.%Y") | mktime) >= ($s | strptime("%d.%m.%Y") | mktime)'
  local EARLIER_THAN_WEEK_END_FILTER='(.date | strptime("%d.%m.%Y") | mktime) <= ($e | strptime("%d.%m.%Y") | mktime)'

  jq --arg s ${week_start_date} --arg e ${week_end_date} \
      ".[] | select(.date != null) | select($LATER_THAN_WEEK_START_FILTER and $EARLIER_THAN_WEEK_END_FILTER)" ${SCHEDULE_JSON} \
    | jq -s 'group_by(.date)[] | group_by(.title)[] | {date: .[0].date, reservations: (.[0].title + " - " + (length|tostring) + "h")}' \
    | jq -s 'group_by(.date)[] | "       ► " + .[0].date + ": " + (map(.reservations | tojson) | unique | join(", "))' \
    | tr -d '\\\\"'
}

function display_additional_info
{
  local reservations_string="$(get_reservations_string)"
  
  #echo "Reservations text: ${reservations_string}"

  if [ -z "${reservations_string}" ]
  then
    send_message "😱 O.M.G. ‼️ У нас нет зарезервированных кортов на этой неделе❗\n\n${CLUB_MANAGER_TELEGRAM_NICK} всё под контролем⁉️"
    #send_sticker "CAACAgIAAxkBAAEEozlidMUCwS_lpQ_UIQRs_j3dkvaNNgACugUAAj-VzArb-JYvDlr2bCQE"
    send_sticker "$(get_random_sticker no-reservation)"
  else
    send_message "✍️ По кортам - у нас забронировано:\n${reservations_string}\n\n${CLUB_MANAGER_TELEGRAM_NICK} ❤️"
    #send_sticker "CAACAgIAAxkBAAEEozdidMSw9bPzUCTgR4lBsv-NQJ98ygACvAUAAj-VzAoTSKpoG9FPRiQE"
    send_sticker "$(get_random_sticker)"
  fi
}

DOW=$(date +%a)

set -x

if [ -n "${DEBUG}" -o "${DOW}" == "Mon" ]; then
  echo "Hooray, it's Monday (${DOW})! Sending the message..."
  
  today_date=$(date +%A", "%d" "%B" "%Y)
  send_message "Привет, мальчики! Сегодня ${today_date}"
  send_poll false false "Кто заряжен на тренировку на этой неделе? 🏸" "👍 Я охеренно заряжен! ⚡" "👎 Не, я пасану... 🥴"
  display_additional_info
else
  echo "Skip sending the message, 'cause it's not Monday (it is $DOW)"
fi
 
