#!/bin/bash

source ./common.sh

verify_root

cp mongo.repo /etc/yum.repos.d/mongodb.repo &>>$LOG_FILE
VERIFY $? "Copying mongo repo file"

dnf install mongodb-org -y &>>$LOG_FILE
VERIFY $? "Installing Mongodb server"

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE
VERIFY $? "Starting Mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VERIFY $? "Editing Mongod config file to enable remote connections"

systemctl restart mongod &>>$LOG_FILE
VERIFY $? "Restarting MongoDB"

print_time