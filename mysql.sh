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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "nodejs disabling"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copying mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysql"

systemctl start mysqld &>> $LOGFILE
 
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Setting root password"