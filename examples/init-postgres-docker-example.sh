#!/bin/sh

# Start the docker image with shell to allow manual execution of Wildfly inside the container
# Inside the container type: 
# ./startup.sh -b 0.0.0.0

docker run -it --entrypoint /bin/bash \
  -e INSTALL_POSTGRES=true \
  -e POSTGRES_VERSION=42.2.5 \
  -e POSTGRES_HOST=localhost \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=mydb \
  -e POSTGRES_DATASOURCE=MYDS \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_USER=myuser \
 fuinorg/wildfly-keycloak-microprofile
 