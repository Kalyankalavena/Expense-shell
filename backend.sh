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

# Create logs folder if not exists
mkdir -p "$LOGS_FOLDER"

echo "Script started executing at: $TIMESTAMP" &>>"$LOG_FILE_NAME"
CHECK_ROOT() {
if [ "$USERID" -ne 0 ]
then
  echo "ERROR:: You must have sudo access to execute this script"
  exit 1
  fi
}  
CHECK_ROOT  

dnf module disable nodejs -y 
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing NodeJS 20"

id expense &>>"$LOG_FILE_NAME"
if [ $? -ne 0 ]
then
  useradd expense 
  VALIDATE $? "Creating expense user"
else
  echo -e "User expense already exists ... $Y SKIPPING $NC" &>>"$LOG_FILE_NAME"
fi  

mkdir /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend"

cd /app 

unzip /tmp/backend.zip
VALIDATE $? "Unzipping backend"

npm install
VALIDATE $? "Installing backend dependencies"

cp /home/ec2-user/Expense-shell/backend.service /etc/systemd/system/backend.service

# prepare mySQL schema

dnf install mysql -y &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing mysql client"

mysql -h mysql.kumareerla.com -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Setting up the transactions schema and tables"

systemctl daemon-reload
VALIDATE $? "Reloading systemd daemons"

systemctl enable backend &>>"$LOG_FILE_NAME"
VALIDATE $? "Enabling backend service"

systemctl start backend &>>"$LOG_FILE_NAME"
VALIDATE $? "Starting backend service"
