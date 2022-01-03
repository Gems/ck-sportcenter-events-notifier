#!/usr/bin/env bash

if [ -z "$TELEGRAM_BOT_TOKEN" -o -z "$TELEGRAM_CHAT_ID" ]; then
  echo "Could not send a notification for the call for RSVP. Telegram token or/and chat aren't configured." >&2
  exit 0
fi

function send_message
{
  local MESSAGE="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"text\": \"$1\"}"
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" -H "Content-Type: application/json" -d "${MESSAGE}" 
}

function send_sticker
{
  local PAYLOAD="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"sticker\": \"$1\"}"
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendSticker" -H "Content-Type: application/json" -d "${PAYLOAD}" 
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
  
  local PAYLOAD="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"question\": \"${question}\", \"is_anonymous\": \"${is_anonymous}\", \"allows_multiple_answers\":\"${allow_multiple_answers}\", \"options\": [${answers}]}"
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPoll" -H "Content-Type: application/json" -d "${PAYLOAD}" 
  #echo ${PAYLOAD}
}


DOW=$(date +%a)

if [ -n "${DEBUG}" -o "${DOW}" == "Mon" ]; then
  echo "Hooray, it's Monday! Sending the message"
  send_poll false false "Мальчики, кто заряжен на тренировку на этой неделе? 🏸" "👍 Я охеренно заряжен! ⚡" "👎 Не, я пасану... 🥴"
  send_message "(Кстати, я пока не умею смотреть в календарь, поэтому убедитесь, что корты зарезервированы)"
  send_sticker "CAACAgIAAxkBAAEDVkFhm6EKnKkvlcvpTHSGfUNGqdtq6QACSAADUomRI27ZLqicPU8AASIE"
else
  echo "Skip sending the message, 'cause it's not Monday (it is $DOW)"
fi
 
