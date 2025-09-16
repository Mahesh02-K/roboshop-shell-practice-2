#!/bin/bash

source ./common.sh
app_name=catalogue

verify_root
nodejs_install
app_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongodb.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VERIFY $? "Installing mongodb client"

STATUS=$(mongosh --host mongodb.kakuturu.store --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.kakuturu.store </app/db/master-data.js &>>$LOG_FILE
    VERIFY $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N" | tee -a $LOG_FILE
fi

print_time