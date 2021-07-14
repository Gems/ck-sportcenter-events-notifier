#!/usr/bin/env bash

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "Could n't send a notification for the call for RSVP. Telegram token isn't configured." >&2
  exit 0
fi

TELEGRAM_CHAT_ID="-488532756"

function send_message
{
  curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
       -H "Content-Type: application/json" 
       -d "{'chat_id': $TELEGRAM_CHAT_ID, 'text': '$1'}" 
}


DOW=$(date +%a)

if [ "$DOW" == "Mon" ]; then
  send_message "Мальчики, кто заряжен на завтрашнюю тренировку? Кстати, я пока не умею смотреть в календарь, поэтому убедитесь, что корты зарезервированы ☝🏻"
fi
 
