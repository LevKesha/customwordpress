FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV APACHE_RUN_DIR="/"
RUN apt update && apt install --yes wget \ 
sudo \ 
apache2 \ 
ghostscript \ 
libapache2-mod-php \ 
mysql-server \ 
php \ 
php-bcmath \ 
php-curl \ 
php-imagick \ 
php-intl \ 
php-json \ 
php-mbstring \ 
php-mysql \ 
php-xml \ 
php-zip
RUN sudo mkdir -p /srv/www && \ 
sudo wget https://wordpress.org/latest.tar.gz && \ 
sudo tar xvzf ./latest.tar.gz -C /srv/www && \ 
sudo chown www-data /srv/www/*
COPY ./wordpress.conf /etc/apache2/sites-available
RUN sudo service apache2 start && \
sudo a2ensite wordpress && \ 
sudo a2enmod rewrite && \ 
sudo a2dissite 000-default && \ 
sudo service apache2 reload
COPY ./mysql.sql ./mysql.sql 
RUN sudo service mysql start && mysql --user=root -e "source mysql.sql"
RUN sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php && \ 
    sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php && \ 
    sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php && \
    sudo -u www-data sed -i 's/password_here/password/' /srv/www/wordpress/wp-config.php
EXPOSE 80
ENTRYPOINT ["sudo","service","apache2","start"]
