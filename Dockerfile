# Unofficial fivefilters Full-Text RSS service
# Enriches third-party RSS feeds with full text articles
# https://bitbucket.org/fivefilters/full-text-rss

FROM	alpine/git AS gitsrc
WORKDIR /ftr
# Bitbucket Full-Text RSS 3.8 only runs on PHP 5. That stack's OpenSSL
# cannot negotiate TLS with current sites. This fork is 3.8.2 with the
# HTTP client and HTML libraries updated for PHP 8.
RUN	git clone https://github.com/Art4/full-text-rss.git . && \
		git reset --hard 66843d0accd0d68bd01873e82616bcafde20bb6a


FROM	alpine/git AS gitconfig
WORKDIR	/ftr-site-config
RUN	git clone https://github.com/fivefilters/ftr-site-config . 


# Bookworm's OpenSSL 3 speaks TLS 1.2 and 1.3.
FROM	php:8.3-apache-bookworm

RUN   apt-get update && \
      apt-get install \
      	-y --no-install-recommends \
      libtidy-dev \
      && rm -rf /var/lib/apt/lists/*

RUN		docker-php-ext-install tidy


COPY --from=gitsrc /ftr /var/www/html
COPY --from=gitconfig /ftr-site-config/.* /ftr-site-config/* /var/www/html/site_config/standard/

RUN		mkdir -p /var/www/html/cache/rss && \
			chmod -Rv 777 /var/www/html/cache && \
			chmod -Rv 777 /var/www/html/site_config

VOLUME	/var/www/html/cache

COPY	custom_config.php /var/www/html/
COPY	docker/php8-compat.sh /tmp/php8-compat.sh
RUN	sh /tmp/php8-compat.sh && rm /tmp/php8-compat.sh

# Keep deprecation warnings out of feed and JSON bodies.
RUN	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

