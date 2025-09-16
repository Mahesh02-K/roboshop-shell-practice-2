#!/bin/bash

source ./common.sh
app_name=shipping

verify_root
echo -e "$Y PLEASE ENTER ROOT PASSWORD TO SETUP $N" | tee -a $LOGS_FILE
read -s MYSQL_ROOT_PASSWORD

app_setup
maven_install
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VERIFY $? "Installing Mysql"

mysql -h mysql.kakuturu.store -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.kakuturu.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.kakuturu.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.kakuturu.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VERIFY $? "Loading data"
else
    echo -e "$Y Data is already Loaded $N" | tee -a $LOGS_FILE
fi

systemctl restart shipping &>>$LOG_FILE
VERIFY $? "Restarting the shipping service"

print_time
