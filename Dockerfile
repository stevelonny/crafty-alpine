
### arguments
ARG CRAFTY_URL=https://gitlab.com/crafty-controller/crafty-4/-/archive/master/crafty-4-master.tar.gz

### builder
FROM python:3-alpine as builder

ARG CRAFTY_URL

### getting builder requirements
RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache \
        build-base \
        cargo \
        git \
        libffi-dev \
        mariadb-dev \
        openssl-dev \
        python3-dev \
        rust
### setup crafty
RUN mkdir /crafty
WORKDIR /crafty
ADD ${CRAFTY_URL} /tmp/
RUN tar xzf /tmp/crafty-4-master.tar.gz --strip-components=1 -C ./
RUN python3 -m venv ./.venv && \
    . .venv/bin/activate && \
    pip3 install --no-cache-dir --upgrade setuptools==50.3.2 pip==22.0.3 && \
    pip3 install --no-cache-dir -r requirements.txt && \
    deactivate
RUN mv ./app/config ./app/config_original && \
    mv ./app/config_original/default.json.example ./app/config_original/default.json
RUN rm -r -f -R /tmp/*

### runtime
FROM python:3-alpine as runtime

COPY --chown=1000 --from=builder /crafty /crafty

### getting runtime packages
RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache \
      curl \
      ca-certificates \
      coreutils \
      libgcc \
      shadow \
      bash \
      sudo \
      tzdata && \
      apk add --no-cache --virtual=build-dependencies --verbose unzip
### install java
RUN wget -O /etc/apk/keys/adoptium.rsa.pub https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk && \
    touch /etc/apk/repositories && \
    echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >> /etc/apk/repositories && \
    apk add --update --no-cache \
        temurin-8-jre \
        temurin-11-jre \
        temurin-17-jre
RUN rm -rf /var/cache/apk/*

### Log4j security patches
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true

### add user crafty
RUN adduser -H -D crafty wheel && \
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel && \
    adduser crafty wheel && \
    chown -R crafty:wheel /crafty
RUN chmod +x ./crafty/docker_launcher.sh

### polishing
USER crafty
WORKDIR /crafty
RUN rm -rf .gitlab .gihtub docs docker config_examples && \
    rm -f .dockerignore .gitignore .editorconfig .gitlab-ci.yml Dockerfile docker-compose.yml docker-compose.yml.example
USER root
RUN sed -i 's/root/wheel/g' docker_launcher.sh
RUN chmod +x ./docker_launcher.sh

# Expose Web Interface port & Server port range
EXPOSE 8000
EXPOSE 8443
EXPOSE 19132
EXPOSE 25500-25600

# Start Crafty through wrapper
ENTRYPOINT ["/crafty/docker_launcher.sh"]
CMD ["-d", "-i"]

