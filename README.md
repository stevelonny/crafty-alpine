# Alpine Linux docker image for Crafty Controller

This is a docker image based on Alpine Linux for [Crafty Controller](https://hub.docker.com/r/arcadiatechnology/crafty-4). Instead of using Ubuntu as base image, this docker image uses Alpine Linux (in its python flavour) and a staged `Dockerfile` to reduce space and memory footprint. 

## Usage

~~You can pull this image either from [Docker hub](https://hub.docker.com/r/stevelonny/crafty-alpine) or [Github Packages](https://ghcr.io/stevelonny/crafty-alpine:latest) by using `docker compose` or `docker run`.~~ Packages hosted on Docker Hub are out of date, and will not receive updates for the near future.

You can build your image by cloning this [Dockerfile](./Dockerfile).

_Instead of installing OpenJDK Java runtimes, this image uses [Adoptium](https://adoptium.net/) Temurin JRE. Beware that automated path recognition of JREs in Crafty could brake, and must resort to manually specify the paths._

Parameters are the same as the ones provided by [Crafty Controller](https://hub.docker.com/r/arcadiatechnology/crafty-4).

### docker-compose.yml
``` yml
version: '3'

services:
crafty:
    container_name: crafty-alpine_container
    image: crafty-alpine
    restart: unless-stopped
    environment:
      - TZ=Etc/UTC
    ports:
      - "8000:8000" # HTTP
      - "8443:8443" # HTTPS
      - "8123:8123" # DYNMAP
      - "19132:19132/udp" # BEDROCK
      - "25500-25600:25500-25600" # MC SERV PORT RANGE
    volumes:
      - ./docker/backups:/crafty/backups
      - ./docker/logs:/crafty/logs
      - ./docker/servers:/crafty/servers
      - ./docker/config:/crafty/app/config
      - ./docker/import:/crafty/import
```

### docker run:
``` sh
$ docker run \
    --name crafty-alpine_container \
    --detach \
    --restart unless-stopped \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8123:8123 \
    -p 19132:19132/udp \
    -p 25500-25600:25500-25600 \
    -e TZ=Etc/UTC \
    -v "/$(pwd)/docker/backups:/crafty/backups" \
    -v "/$(pwd)/docker/logs:/crafty/logs" \
    -v "/$(pwd)/docker/servers:/crafty/servers" \
    -v "/$(pwd)/docker/config:/crafty/app/config" \
    -v "/$(pwd)/docker/import:/crafty/import" \
    crafty-alpine
```
## License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).
