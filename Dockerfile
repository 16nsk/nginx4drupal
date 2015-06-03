FROM debian:jessie

MAINTAINER Gabriel Ignisca "gabriel@designjunkie.com"

# We need to build Nginx with a few modules that will add some magic to Drupal

RUN apt-get update
RUN apt-get install -y gcc g++ make

ENV NGINX_VERSION 1.8.0

COPY zlib-1.2.8 /usr/src/zlib-src
WORKDIR /usr/src/zlib-src
#RUN ./configure --prefix=/usr/local
#RUN make && make install

COPY pcre-8.36 /usr/src/pcre-src
WORKDIR /usr/src/pcre2-src
#RUN ./configure --prefix=/usr/local
#RUN make && make install

COPY nginx-src /usr/src/nginx-src
COPY nginx-upload-progress-module /usr/src/nginx-upload-progress-module

WORKDIR /usr/src/nginx-src

RUN ./configure \
	--user=www-data \
	--with-pcre=../pcre-src \
	--with-zlib=../zlib-src \
	--with-http_realip_module \
	--with-file-aio \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_stub_status_module \
	--add-module=/usr/src/nginx-upload-progress-module
RUN make && make install

COPY nginx /usr/local/nginx/conf

RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log
RUN ln -sf /dev/stderr /usr/local/nginx/logs/error.log

VOLUME ["/usr/local/nginx/cache"]

RUN mkdir -p /usr/local/nginx/cache/microcache \
	&& chown -R www-data:www-data /usr/local/nginx

#EXPOSE 80 443
EXPOSE 80

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
