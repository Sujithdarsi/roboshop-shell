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
        exit 1
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
 
id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "Adding user to roboshop"
else
    echo -e "Already added .... $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
 
VALIDATE $? "Zipping roboshop cart"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping roboshop cart"

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Installing packages"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying cart.service"

systemctl daemon-reload &>> $LOGFILE &>> $LOGFILE

VALIDATE $? "Reloading the daemon"

systemctl enable cart &>> $LOGFILE &>> $LOGFILE

VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart"
