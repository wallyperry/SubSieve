FROM php:8.2-fpm-alpine

RUN apk add --no-cache nginx docker-cli tzdata \
    && echo "date.timezone = Asia/Shanghai" > /usr/local/etc/php/conf.d/timezone.ini \
    && echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf
ENV TZ=Asia/Shanghai

# php-fpm + nginx 配置
COPY nginx.conf /etc/nginx/nginx.conf
COPY src/ /var/www/html/
RUN chown -R nginx:nginx /var/www/html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
