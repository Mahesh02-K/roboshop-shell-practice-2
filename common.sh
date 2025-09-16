#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at :: $(date)" | tee -a $LOG_FILE

app_setup(){
    id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VERIFY $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    mkdir -p /app 
    VERIFY $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VERIFY $? "Downloading $app_name"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VERIFY $? "Unzipping $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VERIFY $? "Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name
    VERIFY $? "Starting $app_name"
}

nodejs_install(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VERIFY $? "Disabling default version of nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VERIFY $? "Enabling version:20 of nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs:20"

    npm install &>>$LOG_FILE
    VERIFY $? "Installing Dependencies"
}

maven_install(){
    dnf install maven -y &>>$LOG_FILE
    VERIFY $? "Install Maven and Java"

    mvn clean package &>>$LOG_FILE
    VERIFY $? "Packaging in shipping application"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VERIFY $? "Moving and renaming the jar file"
}

python_install(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VERIFY $? "Installing python3"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VERIFY $? "Installing Dependancies"
}

verify_root(){
    if [ $USERID -ne 0 ] #checking root privileges
    then
        echo -e "$R ERROR $N:: PLEASE RUN WITH ROOT ACCESS" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo -e "$Y You are running with root access $N" | tee -a $LOG_FILE
    fi
}

VERIFY(){ #Verify function takes input as exit status and what command tried to install
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script execution completed successfully, $Y Time taken = $TOTAL_TIME $N secs " | tee -a $LOG_FILE
}