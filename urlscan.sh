#!/bin/bash
id=$(sed -n '/### Target Group/,/#$$#/p' 'temp/config_mod.ini' | sed '/#/d')
frdid=$(sed -n '/### Forward Id/,/#$$#/p' 'temp/config_mod.ini' | sed '/#/d')
url="$1"
apikey=$(sed -n '/### VT API key/,/#$$#/p' 'temp/config_mod.ini' | sed '/#/d')
token=$(sed -n '/### Bot Token/,/#$$#/p' 'temp/config_mod.ini' | sed '/#/d')
fetch="https://api.telegram.org/bot$token"
urlmsgid="$2"
# Starting
curl --Silent "$fetch/sendMessage?chat_id=$id&text=Scanning The Url🔍" --Output "temp/bot.log"
scan=$(curl -X POST http://www.virustotal.com/vtapi/v2/url/report -F apikey=$apikey -F resource=$url)
rescode=$(echo $scan | jq '.response_code')
if [ "$rescode" == "1" ]; then
  # If URL found into database
  ## Collecting Information
  total=$(echo $scan | jq '.total')
  positives=$(echo $scan | jq '.positives')
  ## Delete Scan message
  msg_id=$(jq '.result.message_id' "temp/bot.log")
  curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
  ## Result
  if [ "$positives" -le "3" ]; then
    curl --Silent "$fetch/sendMessage?chat_id=$id&text=The URL is safe.☑️" --Output "temp/bot.log"
    msg_id=$(jq '.result.message_id' "temp/bot.log")
    sleep 5
    curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
  else
    if [ "$positives" -le "5" ]; then
      curl --Silent "$fetch/forwardMessage?chat_id=$frdid&from_chat_id=$id&message_id=$urlmsgid"
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=$id&text=This Message needs additional Review.📝" --Output "temp/bot.log"
      msg_id=$(jq '.result.message_id' "temp/bot.log")
      sleep 10
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
    else
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=$id&text=The URL is Dangerous.⚠️" --Output "temp/bot.log"
      msg_id=$(jq '.result.message_id' "temp/bot.log")
      sleep 5
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
    fi
  fi
else
  # if url not found into database
  curl -X POST http://www.virustotal.com/vtapi/v2/url/report -F apikey=$apikey -F url=$url
  scan=$(curl -X POST http://www.virustotal.com/vtapi/v2/url/report -F apikey=$apikey -F resource=$url)
  ## Collecting Information
  total=$(echo $scan | jq '.total')
  positives=$(echo $scan | jq '.positives')
  ## Delete Scan message
  msg_id=$(jq '.result.message_id' "temp/bot.log")
  curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
  ## Result
  if [ "$positives" -le "3" ]; then
    curl --Silent "$fetch/sendMessage?chat_id=$id&text=The URL is safe.☑️" --Output "temp/bot.log"
    msg_id=$(jq '.result.message_id' "temp/bot.log")
    sleep 5
    curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
  else
    if [ "$positives" -le "5" ]; then
      curl --Silent "$fetch/forwardMessage?chat_id=$frdid&from_chat_id=$id&message_id=$urlmsgid"
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=$id&text=This Message needs additional Review.📝" --Output "temp/bot.log"
      msg_id=$(jq '.result.message_id' "temp/bot.log")
      sleep 10
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
    else
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=$id&text=The URL is Dangerous.⚠️" --Output "temp/bot.log"
      msg_id=$(jq '.result.message_id' "temp/bot.log")
      sleep 5
      curl --Silent "$fetch/deleteMessage?chat_id=$id&message_id=$msg_id"
    fi
  fi
fi
