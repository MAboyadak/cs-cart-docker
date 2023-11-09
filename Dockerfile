FROM php:8.0.30-apache

# ENV
ENV CS_CART_VERSION 4.17.1
ENV CS_CART_ZIP cscart_v${CS_CART_VERSION}.zip


# working directory in server (entry point)
WORKDIR /var/www/html

COPY ./${CS_CART_ZIP} .

# Install dependencies and PHP exts
RUN apt-get update && \
    apt-get install -y unzip libzip-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libfreetype6-dev libmagickwand-dev && \
    docker-php-ext-install pdo_mysql mysqli curl sockets exif soap zip && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apt-get clean

RUN unzip ${CS_CART_ZIP} && \
    rm ${CS_CART_ZIP} && \
    chown -R www-data:www-data .

# download the paytabs-addon
RUN curl -SL https://github.com/paytabscom/paytabs-cscart/releases/download/3.1.2/paytabs-cscart.zip -o pt2-cscart.zip && \
    unzip -d app/addons pt2-cscart.zip && \
    rm pt2-cscart.zip

# Enable SSL mode & HTTPS website
RUN cd /etc/apache2/sites-available \
    && a2enmod ssl \
    && a2enmod rewrite \ 
    && a2enmod headers \ 
    && service apache2 restart