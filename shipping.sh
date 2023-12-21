#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)

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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

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

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
 
VALIDATE $? "Zipping roboshop shipping"

cd /app 

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping roboshop shipping"

cd /app

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing clean package"

cp shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying shipping.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reloading the daemon"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing mysql"

mysql -h mysql.daws23.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Adding Host IP mysql"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting shipping"
