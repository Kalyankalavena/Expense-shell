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

dnf install mysql-server -y &>>"$LOG_FILE_NAME"
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>"$LOG_FILE_NAME"
VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>>"$LOG_FILE_NAME"
VALIDATE $? "Starting mysql server"

mysql -h mysql.kumareerla.com -u root -pExpenseApp@1 -e "show databases" &>>"$LOG_FILE_NAME"

if [ $? -ne 0 ]
then
  echo -e "MySQL root password not setup" &>>"$LOG_FILE_NAME"
  mysql_secure_installation --set-root-pass ExpenseApp@1 &>>"$LOG_FILE_NAME"
  VALIDATE $? "Setting mysql root password"
else
    echo -e "MySQL root password already setup  ... $Y SKIPPING" $N &>>"$LOG_FILE_NAME"
fi

echo -e "\nMySQL Setup Completed Successfully\n"


