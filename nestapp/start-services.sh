#!/bin/bash


#Create the /run/php-fpm/ Directory
mkdir -p /run/php-fpm

#Start php-fpm in the background
php-fpm -D

#Start Apache in the foreground 
/usr/sbin/httpd -D FOREGROUND