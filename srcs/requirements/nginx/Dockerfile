FROM debian:bookworm-slim

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create SSL directory and generate self-signed certificate
RUN mkdir -p /etc/nginx/ssl /var/www/wordpress && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mlabrirh.42.fr/UID=mlabrirh"

# Remove default site configs
RUN rm -rf /etc/nginx/sites-enabled/* /etc/nginx/conf.d/*

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
