#!/bin/sh

# Patch a local version of Wildfly
# You need to adjust the "wildflyHome" variable below to point to the right directory

./init-wildfly-mgmt-services.sh \
  --wildflyHome="/home/developer/Downloads/wildfly-14.0.1.Final" \
  --keycloakVersion="4.5.0.Final" \
  --keycloakServerUrl="http://localhost:8180/auth" \
  --keycloakRealmPublicKey="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmAFTCSVf7onYIK76usq9sF6hsLvmzarXYZOgJPsD6dsPzvk9e+09jbB96LeFg+S88gSTRwuxLYyMjSe6+zUCThNnX785momaxqs9VxjAXG0qkmpx1a/iD5RMdrsMfDwBZwcYiJtPncC5g9dtN0C0dMckLRUsg1zuQ5KmiJZQIGtse7BFwbtwYAhmYeYhJSqdS6rYdf/8gRLpHU4StRAjU+/dkDXJuXiXMBy65LfAX+SpQtpgKpcFK0u8FA9WsB5x4OeqYe+cyUUbsQe2gq7hm/iLVEOHYg+Xk+23jpFBinbRIjjveDf6IYkde4PUX7Y3ZRuTiD48TnohtwMK5RZpVwIDAQAB"  
  