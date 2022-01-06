#!/bin/bash
# Loding Configuration File
source bot.conf
# ----- Setting Up
fetch="https://api.telegram.org/bot${BOTTOKEN}"
curl --Silent "$fetch/getUpdates" --Output "temp/log.txt"
hash0=$(sha256sum "temp/log.txt")
rm "temp/log.txt"
spaceloc=$(expr index "$hash0" " ")
hash0=${hash0:0:$spaceloc}
# ------------ Start Shell
while [ "1" -eq "1" ]
do
  curl --Silent "$fetch/getUpdates" --Output "temp/log.txt"
  # Reload after 90-100 Messages
  msgscou=$(($(wc -l < "temp/log.txt") + 1))
  if [ "$msgscou" -ge "90" ]; then
    # Getting Last Update id
    update_id=$(jq '.result[].update_id' "temp/log.txt" | tail -1)
    curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Reloading Offset Databases🔄" --Output "temp/bot.log"
    clearoffset=$(($update_id + 1))
    curl --Silent "$fetch/getUpdates?offset=$clearoffset"
    # Deleting Output After 3 Seconds
    msg_id=$(jq '.result.message_id' "temp/bot.log")
    sleep 3
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
  fi
  # ---------------------------------------------------------
  hash1=$(sha256sum "temp/log.txt")
  spaceloc=$(expr index "$hash0" " ")
  hash1=${hash1:0:$spaceloc}
  # If hash value same then loop
  if [ "$hash0" == "$hash1" ]; then
    continue
  fi
  hash0="$hash1"
  # If Hash Value Not Matched then do below operations
  ## Leave Not Permitted Group
  leave=$(jq '.result[].message.new_chat_member.username' "temp/log.txt" | tail -1 | grep -c "TechSoulsBot")
  if [ "$leave" == "1" ]; then
    grp_id=$(jq '.result[].message.chat.id' "temp/log.txt" | tail -1)
    tmp="${ALLOW%%$TARGETGROUP*}"
    if [ "$ALLOW" != "$tmp" ]; then
      break
    else
      curl --Silent "$fetch/sendMessage?chat_id=$grp_id&text=You don't have Permission to Add me in this Group, At first Take Permission from @BiltuDas1 to add me in this group."
      curl --Silent "$fetch/leaveChat?chat_id=$grp_id"
    fi
  fi
  ## Online function
  online=$(jq '.result[].message.text' "temp/log.txt" | tail -1 | grep -c "/online")
  if [ "$online" == "1" ]; then
    online="0"
    # Deleting Command Message
    msg_id=$(jq '.result[].message.message_id' "temp/log.txt" | tail -1)
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Bot Status: Online✅" --Output "temp/bot.log"
    # Deleting Output After 5 Seconds
    msg_id=$(jq '.result.message_id' "temp/bot.log")
    sleep 5
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    continue
  fi
  ## Restart
  restart=$(jq '.result[].message.text' "temp/log.txt" | tail -1 | grep -c "/restartbot")
  if [ "$restart" == "1" ]; then
    restart="0"
    # Deleting Command Message
    msg_id=$(jq '.result[].message.message_id' "temp/log.txt" | tail -1)
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    exit
  fi
  ## Remove Known Spammers while Joining
  user=$(cat "temp/log.txt" | tail -1 | grep -c "new_chat_participant")
  user=$(($(cat "temp/log.txt" | tail -1 | grep -c "new_chat_member") + $user))
  user=$(($(cat "temp/log.txt" | tail -1 | grep -c "new_chat_members") + $user))
  if [ "$user" -ne "3" ]; then
    user_id="null"
  fi
  until [ "$user_id" == "null" ]
  do
    user=0
    user_id=$(jq ".result[].message.new_chat_members[$user].id" "temp/log.txt" | tail -1)
    user=$(($user + 1))
    ban=$(curl --Silent "https://api.cas.chat/check?user_id=$user_id" | jq '.ok')
    firstname=$(jq ".result[].message.new_chat_members[$user].first_name" "temp/log.txt" | tail -1)
    firstname=${firstname:1:-1}
    if [ "$ban" == "true" ]; then
      curl --Silent "$fetch/banChatMember?chat_id=${TARGETGROUP}&user_id=$user_id"
      curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=$firstname banned from this Group due to previously abusing with another group members." --Output "temp/bot.log"
      # Deleting Output After 5 Seconds
      msg_id=$(jq '.result.message_id' "temp/bot.log")
      sleep 5
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    fi
  done

  ## Delete Messages
  del=$(jq '.result[].message.text' "temp/log.txt" | tail -1 | grep -c "/del")
  if [ "$del" == "1" ]; then
    # Deleting Mention Message
    msg_id=$(jq '.result[].message.reply_to_message.message_id' "temp/log.txt" | tail -1)
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    # Deleting Command Message
    msg_id=$(jq '.result[].message.message_id' "temp/log.txt" | tail -1)
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    # Send User a message that Delete Complete
    curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Delete Completed!" --Output "temp/bot.log"
    # Deleting Delete Complete Message After 3 Seconds
    msg_id=$(jq '.result.message_id' "temp/bot.log")
    sleep 3
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    del=0
    continue
  fi
  # Scan Webpage
  ## Detect Url from Message
  url=$(jq ".result[].message.entities[0].type" "temp/log.txt" | tail -1 | grep -c "url")
  urltext=$(jq ".result[].message.text" "temp/log.txt" | tail -1)
  scanen=$(echo $urltext | grep -c 'http\://')
  scanen=$(($(echo $urltext | grep -c 'https\://') + $scanen))
  if [ "$scanen" -ge "1" ]; then
    echo $urltext | grep -oP 'http.?://\S+' > "temp/urllist.txt"
    # Extracting Message Id
    msg_id=$(jq '.result[].message.message_id' "temp/log.txt" | tail -1)
    head=0
    until [ "1" == "1"]
    do
      head=$(($head + 1))
      urlold=$url
      url=$(cat "temp/urllist.txt" | head -$head | tail -1)
      # An URL Scanning Bug
      url=$(echo ${url::-1} | awk -F[/:] '{print $4}')
      if [ "$urlold" == "$url" ]; then
        break
      fi
      # Run Scanner
      nice bash urlscan.sh "$url" "$msg_id" &>> "log/urlscan.log" 1>&2
      wait
    done
  else
    if [ "$url" -eq "1" ]; then
      curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Scan Failed! Reason: URL must contains http or https protocol." --Output "temp/bot.log"
      msg_id=$(jq '.result.message_id' "temp/bot.log")
      sleep 7
      curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
    fi
  fi
  # Save Note
  note=$(jq '.result[].message.text' "temp/log.txt" | tail -1 | grep -c "/savenote")
  if [ "$note" == "1" ]; then
    note=$(jq '.result[].message.text' "temp/log.txt" | tail -1)
    note=${note//\/savenote/}
    note=${note//\"/}
    msg_id=$(jq '.result[].message.reply_to_message.message_id' "temp/log.txt" | tail -1)
    curl --Silent "$fetch/copyMessage?chat_id=-1001581134878&from_chat_id=${TARGETGROUP}&message_id=$msg_id" --Output "temp/saveid.txt"
    msg_id=$(jq '.result.message_id' "temp/saveid.txt")
    echo $msg_id $note >>"settings/note.txt"
    curl --Silent "$fetch/sendMessage?chat_id=${TARGETGROUP}&text=Your Note has been Saved, It can be access using `::$note` command" --Output "temp/bot.log"
    msg_id=$(jq '.result.message_id' "temp/bot.log")
    sleep 5
    curl --Silent "$fetch/deleteMessage?chat_id=${TARGETGROUP}&message_id=$msg_id"
  fi
  # Get Notes
  getnote=$(jq '.result[].message.text' "temp/log.txt" | tail -1 | grep -c "::")
  if [ "$getnote" == "1" ]; then
    # Getting NoteName
    getnote=$(jq '.result[].message.text' "temp/log.txt" | tail -1)
    getnote=${getnote#*::}
    # Bug in Getting Notes
    getnote=${getnote//\"/}
    tmp=($getnote)
    getnote=${tmp[0]}
    notefou=$(grep -cr "\b$getnote\b" "settings/note.txt")
    if [ "$notefou" == "1" ]; then
      notefou=$(grep -r "\b$getnote\b" "settings/note.txt")
      tmp=($notefou)
      notefou=${tmp[0]}
      curl --Silent "$fetch/copyMessage?chat_id=${TARGETGROUP}&from_chat_id=-1001581134878&message_id=$notefou"
    fi
  fi
done
exit
# ------------- Shell Closed
