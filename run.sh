#!/bin/bash
mkdir temp log
# Lading Configuration File
source bot.conf
fetch="https://api.telegram.org/bot${BOTTOKEN}"
restart=1
while [ "$restart" -eq "1" ]
do
  # Collect Admin Information
  curl --Silent "$fetch/getChatAdministrators?chat_id=${TARGETGROUP}" --Output "temp/admin.log"
  jq '.result[].user.id' "temp/admin.log" > "temp/adminid.log"
  # Run Main Interface
  nice bash proc.sh &>> "log/proc.log" 1>&2
  # ------------------
  wait
  curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Bot Restarted♻️" --Output "temp/bot.log"
  # Delete Output after 3 Seconds
  msg_id=$(jq '.result.message_id' "temp/bot.log")
  sleep 3
  curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
done
