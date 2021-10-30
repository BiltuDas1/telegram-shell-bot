#!/bin/bash
mkdir temp log
# Lading Configuration File
confline=$(wc -l < 'config.ini')
grep -A $confline "#2#" 'config.ini' | tail -n +2 > 'temp/config_mod.ini'
# Setting Up
id=$(sed -n '/### Target Group/,/#$$#/p' 'temp/config_mod.ini' | sed '/#/d')
token=$(sed -n '/### Bot Token/,/#$$#/p' 'temp/config_mod.ini' | sed '/#/d')
fetch="https://api.telegram.org/bot$token"
restart=1
while [ "$restart" -eq "1" ]
do
  # Collect Admin Information
  curl --Silent "$fetch/getChatAdministrators?chat_id=$id" --Output "temp/admin.log"
  jq '.result[].user.id' "temp/admin.log" > "temp/adminid.log"
  # Run Main Interface
  nice bash proc.sh &>> "log/proc.log" 1>&2
  # ------------------
  wait
  curl --Silent "$fetch/sendMessage?chat_id=$id&text=Bot Restarted♻️" --Output "temp/bot.log"
  # Delete Output after 3 Seconds
  msg_id=$(jq '.result.message_id' "temp/bot.log")
  sleep 3
  curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
done
