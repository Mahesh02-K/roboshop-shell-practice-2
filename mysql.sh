#!/bin/bash

source ./common.sh

verify_root

echo "Please enter password to setup"
read -s MYSQL_ROOT_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VERIFY $? "Installing mysql" 

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld &>>$LOG_FILE
VERIFY $? "Starting mysql"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VERIFY $? "Setting MySQL root password"

print_time