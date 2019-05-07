#!/bin/sh

# Start the docker image with shell to allow manual execution of Wildfly inside the container
# Inside the container type: 
# ./startup.sh -b 0.0.0.0

docker run -it --entrypoint /bin/bash \
  -e INSTALL_WILDFLY_MGMT_SERVICE=true \
  -e KEYCLOAK_SERVER_URL="http://localhost:8180/auth" \
  -e KEYCLOAK_REALM_PUBLIC_KEY="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmAFTCSVf7onYIK76usq9sF6hsLvmzarXYZOgJPsD6dsPzvk9e+09jbB96LeFg+S88gSTRwuxLYyMjSe6+zUCThNnX785momaxqs9VxjAXG0qkmpx1a/iD5RMdrsMfDwBZwcYiJtPncC5g9dtN0C0dMckLRUsg1zuQ5KmiJZQIGtse7BFwbtwYAhmYeYhJSqdS6rYdf/8gRLpHU4StRAjU+/dkDXJuXiXMBy65LfAX+SpQtpgKpcFK0u8FA9WsB5x4OeqYe+cyUUbsQe2gq7hm/iLVEOHYg+Xk+23jpFBinbRIjjveDf6IYkde4PUX7Y3ZRuTiD48TnohtwMK5RZpVwIDAQAB" \
 fuinorg/wildfly-keycloak-microprofile
 