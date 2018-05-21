FROM alpine:3.7

RUN addgroup -g 82 -S www-data && adduser -u 82 -D -S -H -G www-data www-data

RUN apk update && \
    apk add bash less vim nginx ca-certificates git tzdata zip \
    libmcrypt-dev zlib-dev gmp-dev \
    freetype-dev libjpeg-turbo-dev libpng-dev \
    php7-fpm php7-json php7-zlib php7-xml php7-pdo php7-phar php7-openssl \
    php7-pdo_mysql php7-mysqli php7-session \
    php7-gd php7-iconv php7-mcrypt php7-gmp php7-zip \
    php7-curl php7-opcache php7-ctype php7-apcu \
    php7-intl php7-bcmath php7-dom php7-mbstring php7-xmlreader mysql-client curl && apk add -u musl && \
    rm -rf /var/cache/apk/*

RUN sed -i  -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' \
            -e 's/expose_php = On/expose_php = Off/g' \
    /etc/php7/php.ini

ENV WORDPRESS_VERSION 4.9.6
RUN curl -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" | \
    tar xzf - -C /usr/local/share/ && \
    chown -R www-data:www-data /usr/local/share/wordpress

RUN rm -rf /var/www/* && mkdir /var/www/html && chown -R www-data:www-data /var/www/html && \
    cp -a /usr/local/share/wordpress/. /var/www/html/

VOLUME ["/var/www/html"]

ENV WORDPRESS_CLI_VERSION 1.5.1
RUN curl -o /usr/local/bin/wp-cli -fSL "https://github.com/wp-cli/wp-cli/releases/download/v${WORDPRESS_CLI_VERSION}/wp-cli-${WORDPRESS_CLI_VERSION}.phar" && \
    chmod +x /usr/local/bin/wp-cli
COPY nginx.conf /etc/nginx/
COPY php-fpm.conf /etc/php7/
COPY phpfpm-nginx.sh /usr/local/bin/
COPY wait-for.sh /usr/local/bin/
COPY wp-cli-wrapper.sh /usr/local/bin/wp

RUN chmod +x /usr/local/bin/phpfpm-nginx.sh /usr/local/bin/wait-for.sh /usr/local/bin/wp

EXPOSE 80

WORKDIR /var/www/html

CMD ["phpfpm-nginx.sh"]
