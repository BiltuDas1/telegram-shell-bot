# Telegram Shell Bot (Self Hosted)
## How to use
It is self hosted bot, you are the owner of the bot, all private chats will be show to you and chat participants only. Any outsider can't see what actually happening into your group, you need to manually setup it into a server where it will run for 24/7.
## Create a New Bot
1. Call [@Botfather](https://telegram.me/BotFather)
2. Type `/start` and after that type `/newbot` to create a new bot
3. Now Type a Name and Username for that bot.
4. Now All done Make sure to Copy that API token

## Installing TSB
### Google Colab
<a href="https://colab.research.google.com/github/BiltuDas1/telegram-shell-bot/blob/main/Bot.ipynb"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"></a>  
Use Ctrl+Click or CMD+Click to open in a New window  

### PythonAnywhere
1. At first [Log In](https://www.pythonanywhere.com/login/) or [Create Account](https://www.pythonanywhere.com/registration/register/beginner/) and Open PythonAnywhere Dashboard.
2. Under New Colsole Click on Bash (It will create New Bash Console)
3. Into Console Type
```
git clone https://github.com/BiltuDas1/telegram-shell-bot.git
cd telegram-shell-bot
mv * ..
cd ..
rm -d telegram-shell-bot
```
4. Now click on the Menu bar and then choose Files, from that list choose config.ini, into there config Target Group, Forward Id, Bot Token etc. If you have any issue then you can ask it into [Telegram](https://telegram.me/techsouls0)
5. Now press browser back button to come on console and Start the Bot using
```
bash run.sh
```
All Done, Use /online command.

## Restriction of Free Version of Server
### Google Colab
1. You need to visit that Google Colab script webpage into every 90 minutes so that your colab notebook will not be into idle mode (Note: It will not work more than 12 hours, after 12 hours you need to start that colab notebook manually, make sure to backup config.ini)

### PythonAnywhere
1. Free Version Server has 100 Seconds Tarpit. If 100 seconds completed then bot will be work little bit slow, and sometime terminate. (Don't worry that script will be enable it automatically. make sure to use /online command for checking bot is working or not)
2. This method is not recommended for large Groups.
