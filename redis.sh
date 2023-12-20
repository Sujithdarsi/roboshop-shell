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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> LOGFILE

VALIDATE $? "Installing remirepo"

dnf module enable redis:remi-6.2 -y &>> LOGFILE

VALIDATE $? "Enabling redis"

dnf install redis -y &>> LOGFILE

VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> LOGFILE

VALIDATE $? "Configuring local host"

systemctl enable redis &>> LOGFILE

VALIDATE $? "Enabling redis"

systemctl start redis &>> LOGFILE

VALIDATE $? "starting redis"