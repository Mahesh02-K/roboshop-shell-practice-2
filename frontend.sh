#!/bin/bash

source ./common.sh
verify_root

dnf module disable nginx -y &>>$LOG_FILE
VERIFY $? "Disabling default nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VERIFY $? "Enabling nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VERIFY $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VERIFY $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VERIFY $? "Removing Default Content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VERIFY $? "Downloading Frontend Content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VERIFY $? "Unzipping frontend Content"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VERIFY $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VERIFY $? "Copying Nginx conf file"

systemctl restart nginx &>>$LOG_FILE
VERIFY $? "Restarting nginx"

print_time





