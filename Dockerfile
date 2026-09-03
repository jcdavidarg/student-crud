FROM debian:bookworm-slim

# ============================================================
# Apache + Perl CGI + DBD::Pg — app "student-crud"
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        libcgi-pm-perl \
        libdbi-perl \
        libdbd-pg-perl \
        libjson-pp-perl \
        postgresql-client \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Habilitar modulo CGI y mod_rewrite, y quitar el ScriptAlias /cgi-bin/
# global (serve-cgi-bin.conf) que apunta a /usr/lib/cgi-bin y choca con
# nuestro directorio cgi-bin dentro del DocumentRoot.
RUN a2enmod cgi rewrite \
    && a2disconf serve-cgi-bin

# Copiar la aplicacion
WORKDIR /var/www/app
COPY . /var/www/app

# Configurar Apache para servir la app en la raiz con soporte CGI
COPY docker/apache-site.conf /etc/apache2/sites-available/000-default.conf

# Marcas de directorio / asegurar que el PROJECT_ROOT para Config.pm este
# en /var/www/app (ya lo es por el WORKDIR + COPY).

RUN chown -R www-data:www-data /var/www/app \
    && chmod +x /var/www/app/cgi-bin/*.pl

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
