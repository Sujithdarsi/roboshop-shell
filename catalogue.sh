#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)

MONGO_HOST=mongodb.daws23.online

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){

    if [ $1 -ne 0 ]
    then
        echo -e " $2 ... $R Installation Unsuccessful $N "
    else
        echo -e " $2 ... $G Installion Successful $N "
    fi

}

if [ $ID -ne 0 ]
then
    echo -e " $R Error : You are not root user,please run by root user $N "
    exit 1
else
    echo -e " $G You are root user $N "
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "nodejs disabling"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs"
 
useradd roboshop &>> $LOGFILE

VALIDATE $? "Adding user to roboshop"

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
 
VALIDATE $? "Zipping roboshop catalogue"

cd /app 

unzip /tmp/catalogue.zip 

VALIDATE $? "Unzipping roboshop catalogue"

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Installing packages"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service  &>> $LOGFILE

VALIDATE $? "Adding data to catalogue.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reloading the daemon"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongodb repo "

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $MONGO_HOST </app/schema/catalogue.js &>> 
 
VALIDATE $? "Adding mongodb host address to catalogue "