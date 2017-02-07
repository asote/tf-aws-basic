#!/bin/bash
yum install mysql-server -y
yum update -y
systemctl start mysqld
