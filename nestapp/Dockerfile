# Use the latest version of the Amazon Linux base image
FROM amazonlinux:2

# Update all installed packages to thier latest versions
RUN yum update -y 

# Install the unzip package, which we will use it to extract the web files from the zip folder
RUN yum install unzip -y

# Install wget package, which we will use it to download files from the internet 
RUN yum install -y wget

# Install Apache
RUN yum install -y httpd


# Install PHP and various extensions
RUN amazon-linux-extras enable php8.0 && \
  yum clean metadata && \
  yum install -y \
    php-cli \
    php-fpm \
    php-mysqlnd \
    php-bcmath \
    php-ctype \
    php-fileinfo \
    php-json \
    php-mbstring \
    php-openssl \
    php-pdo \
    php-gd \
    php-tokenizer \
    php-xml \
    php-curl

# Download the MySQL repository package
RUN wget https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm

# Import the GPG key for the MySQL repository
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# Install the MySQL repository package
RUN yum localinstall mysql80-community-release-el7-3.noarch.rpm -y

# Install the MySQL community server package
RUN yum install mysql-community-server -y

# Modify php.ini settings
RUN sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php.ini && \
    sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php.ini


# Change directory to the html directory
WORKDIR /var/www/html

# Install Git
RUN yum install -y git

# Set the build argument directive
ARG PERSONAL_ACCESS_TOKEN
ARG GITHUB_USERNAME
ARG REPOSITORY_NAME
ARG WEB_FILE_ZIP
ARG WEB_FILE_UNZIP
ARG DOMAIN_NAME
ARG RDS_ENDPOINT
ARG RDS_DB_NAME
ARG RDS_MASTER_USERNAME
ARG RDS_DB_PASSWORD

# Use the build argument to set environment variables 
ENV PERSONAL_ACCESS_TOKEN=$PERSONAL_ACCESS_TOKEN
ENV GITHUB_USERNAME=$GITHUB_USERNAME
ENV REPOSITORY_NAME=$REPOSITORY_NAME
ENV WEB_FILE_ZIP=$WEB_FILE_ZIP
ENV WEB_FILE_UNZIP=$WEB_FILE_UNZIP
ENV DOMAIN_NAME=$DOMAIN_NAME
ENV RDS_ENDPOINT=$RDS_ENDPOINT
ENV RDS_DB_NAME=$RDS_DB_NAME
ENV RDS_MASTER_USERNAME=$RDS_MASTER_USERNAME
ENV RDS_DB_PASSWORD=$RDS_DB_PASSWORD

# Clone the GitHub repository
RUN git clone https://$GITHUB_USERNAME:$PERSONAL_ACCESS_TOKEN@github.com/az-salu/nest-app-code.git /var/www/html
#RUN unzip nest-app-code.zip -d nest-app-code




# Remove the repository we cloned
RUN rm -rf nest-app-code -d nest-app-code.zip

RUN mkdir -p /var/www/html/storage && chmod -R 777 /var/www/html/storage


# Enable the mod_rewrite setting in the httpd.conf file
RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Give full access to the /var/www/html directory
RUN chmod -R 777 /var/www/html

# Give full access to the storage directory
RUN chmod -R 777 storage/

# Use the sed command to search the .env file for a line that starts with APP_ENV= and replace everything after the = character
RUN sed -i '/^APP_ENV=/ s/=.*$/=production/' .env

# Use the sed command to search the .env file for a line that starts with APP_URL= and replace everything after the = character
RUN sed -i "/^APP_URL=/ s/=.*$/=https:\/\/$DOMAIN_NAME\//" .env

# Use the sed command to search the .env file for a line that starts with DB_HOST= and replace everything after the = character
RUN sed -i "/^DB_HOST=/ s/=.*$/=$RDS_ENDPOINT/" .env

# Use the sed command to search the .env file for a line that starts with DB_DATABASE= and replace everything after the = character
RUN sed -i "/^DB_DATABASE=/ s/=.*$/=$RDS_DB_NAME/" .env 

# Use the sed command to search the .env file for a line that starts with DB_USERNAME= and replace everything after the = character
RUN  sed -i "/^DB_USERNAME=/ s/=.*$/=$RDS_MASTER_USERNAME/" .env

# Use the sed command to search the .env file for a line that starts with DB_PASSWORD= and replace everything after the = character
RUN  sed -i "/^DB_PASSWORD=/ s/=.*$/=$RDS_DB_PASSWORD/" .env

# Copy the file, AppServiceProvider.php from the host file system into the container at the path app/Providers/AppServiceProvider.php
COPY AppServiceProvider.php app/Providers/AppServiceProvider.php

# Expose the default Apache and MySQL ports
EXPOSE 80 3306

# Copy the start-services script into the container
COPY start-services.sh /usr/local/bin/start-services.sh


#Ensure the script is executable
RUN chmod +x /usr/local/bin/start-services.sh

# Run the script to start both PHP-FPM and Apache 
CMD ["/usr/local/bin/start-services.sh"]