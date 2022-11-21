#!/bin/bash
source bot.conf
url="$1"
fetch="https://api.telegram.org/bot${BOTTOKEN}"
urlmsgid="$2"
# Starting
curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Scanning The Url🔍" --Output "${WORKINGDIR}/temp/bot.log"
scan=$(curl -X POST http://www.virustotal.com/vtapi/v2/url/report -F apikey=${VTKEY} -F resource=$url)
rescode=$(echo $scan | jq '.response_code')
if [ "$rescode" == "1" ]; then
  # If URL found into database
  ## Collecting Information
  total=$(echo $scan | jq '.total')
  positives=$(echo $scan | jq '.positives')
  ## Delete Scan message
  msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
  curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
  ## Result
  if [ "$positives" -le "3" ]; then
    curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=The URL is safe.☑️" --Output "${WORKINGDIR}/temp/bot.log"
    msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
    sleep 5
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
  else
    if [ "$positives" -le "5" ]; then
      curl --Silent "$fetch/forwardMessage?chat_id=${FORWARDID}&from_chat_id=${TARGETGROUP}&message_id=$urlmsgid"
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=This Message needs additional Review.📝" --Output "${WORKINGDIR}/temp/bot.log"
      msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
      sleep 10
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    else
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=The URL is Dangerous.⚠️" --Output "${WORKINGDIR}/temp/bot.log"
      msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
      sleep 5
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    fi
  fi
else
  # if url not found into database
  curl -X POST http://www.virustotal.com/vtapi/v2/url/report -F apikey=${VTKEY} -F url=$url
  scan=$(curl -X POST http://www.virustotal.com/vtapi/v2/url/report -F apikey=${VTKEY} -F resource=$url)
  ## Collecting Information
  total=$(echo $scan | jq '.total')
  positives=$(echo $scan | jq '.positives')
  ## Delete Scan message
  msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
  curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
  ## Result
  if [ "$positives" -le "3" ]; then
    curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=The URL is safe.☑️" --Output "${WORKINGDIR}/temp/bot.log"
    msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
    sleep 5
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
  else
    if [ "$positives" -le "5" ]; then
      curl --Silent "$fetch/forwardMessage?chat_id=${FORWARDID}&from_chat_id=${TARGETGROUP}&message_id=$urlmsgid"
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=This Message needs additional Review.📝" --Output "${WORKINGDIR}/temp/bot.log"
      msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
      sleep 10
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    else
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$urlmsgid"
      curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=The URL is Dangerous.⚠️" --Output "${WORKINGDIR}/temp/bot.log"
      msg_id=$(jq '.result.message_id' "${WORKINGDIR}/temp/bot.log")
      sleep 5
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    fi
  fi
fi
