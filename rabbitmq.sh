#!/bin/bash

source ./common.sh
app_name=rabbitmq

verify_root

echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VERIFY $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VERIFY $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VERIFY $? "Enabling rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VERIFY $? "Starting rabbitmq server"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE

print_time