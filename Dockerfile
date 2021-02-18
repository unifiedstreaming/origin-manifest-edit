FROM alpine:3.12

ARG REPO=http://stable.apk.unified-streaming.com/alpine/v3.12

# install latest beta build & apache
RUN apk \
    --update \
    --repository $REPO \
    --allow-untrusted \
    add \
        python3 \
        py3-pip \
        apache2 \
        mp4split=1.10.28-r0 \
        mod_smooth_streaming=1.10.28-r0 \
        manifest-edit=1.10.28-r0 \
    && pip3 install \
        pyyaml==5.3.1 \
        schema==0.7.3 \
    && rm -f /var/cache/apk/*

RUN mkdir -p /run/apache2 \
    && ln -s /dev/stderr /var/log/apache2/error.log \
    && ln -s /dev/stdout /var/log/apache2/access.log \
    && mkdir -p /var/www/unified-origin

COPY httpd.conf /etc/apache2/httpd.conf
COPY unified-origin.conf.in /etc/apache2/conf.d/unified-origin.conf.in
COPY s3_auth.conf.in /etc/apache2/conf.d/s3_auth.conf.in
COPY remote_storage.conf.in /etc/apache2/conf.d/remote_storage.conf.in
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY index.html /var/www/unified-origin/index.html
COPY clientaccesspolicy.xml /var/www/unified-origin/clientaccesspolicy.xml
COPY crossdomain.xml /var/www/unified-origin/crossdomain.xml

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["-D", "FOREGROUND"]