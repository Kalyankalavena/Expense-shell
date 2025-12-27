#!/bin/bash

#!/bin/bash
echo -e "\nThis script demonstrates the use of colours in bash scripting\n"

USERID=$(id -u)

R="\e[0;31m"
G="\e[0;32m"
Y="\e[0;33m"
NC="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/${LOG_FILE}-${TIMESTAMP}.log"

VALIDATE() {
  if [ $1 -ne 0 ]
  then
    echo -e "$2 ... ${R}FAILURE${NC}"
    exit 1
  else
    echo -e "$2 ... ${G}SUCCESS${NC}"
  fi
}

CHECK_ROOT() {
if [ "$USERID" -ne 0 ]
then
  echo "ERROR:: You must have sudo access to execute this script"
  exit 1 #other than 0
fi
}  

echo "Script started executing at: $TIMESTAMP" &>>"$LOG_FILE_NAME"
CHECK_ROOT  

dnf install nginx -y &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>"$LOG_FILE_NAME"
VALIDATE $? "Enabling Nginx"        

systemctl start nginx &>>"$LOG_FILE_NAME"
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>"$LOG_FILE_NAME"
VALIDATE $? "removing existing nginx of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>"$LOG_FILE_NAME"
VALIDATE $? "Downloading latest code"

cd /usr/share/nginx/html/ &>>"$LOG_FILE_NAME"
VALIDATE $? "moving to html directory"

unzip /tmp/frontend.zip &>>"$LOG_FILE_NAME"
VALIDATE $? "Unzipping frontend code"

systemctl restart nginx &>>"$LOG_FILE_NAME"
VALIDATE $? "Restarting Nginx"