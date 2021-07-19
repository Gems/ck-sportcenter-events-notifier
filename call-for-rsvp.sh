#!/usr/bin/env bash

if [ -z "$TELEGRAM_BOT_TOKEN" -o -z "$TELEGRAM_CHAT_ID" ]; then
  echo "Could not send a notification for the call for RSVP. Telegram token or/and chat aren't configured." >&2
  exit 0
fi

function send_message
{
  local MESSAGE="{\"chat_id\": $TELEGRAM_CHAT_ID, \"text\": \"$1\"}"
  curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -H "Content-Type: application/json" -d "${MESSAGE}" 
}


DOW=$(date +%a)

if [ "$DOW" == "Mon" ]; then
  echo "Hooray, it's Monday! Sending the message"
  send_message "Мальчики, кто заряжен на завтрашнюю тренировку? Кстати, я пока не умею смотреть в календарь, поэтому убедитесь, что корты зарезервированы."
else
  echo "Skip sending the message, 'cause it's not Monday ($DOW)"
fi
 
