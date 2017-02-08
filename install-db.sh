#!/bin/bash
yum install mysql-server -y
yum update -y
service mysqld start
