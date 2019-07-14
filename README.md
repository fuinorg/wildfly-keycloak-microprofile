# wildfly-keycloak-microprofile
Wildfly Docker image for Java EE microservices with Keycloak, Microprofile and an optional PostgreSQL data source. Allows easy setup of your docker container at first startup.

[![Automated Docker Build](https://img.shields.io/docker/automated/fuinorg/wildfly-keycloak-microprofile.svg)](https://hub.docker.com/r/fuinorg/wildfly-keycloak-microprofile/)

## Versions
- Wildfly Base Image: 16.0.0.Final
- Keycloak Adapter: 6.0.1
- logstash-gelf: 1.12.0

## Features

- **Protect your JEE microservice or application with the Wildfly Keycloak Adapter**
  - Basically the same as official [Keycloak Wildfly Adapter](https://github.com/jboss-dockerfiles/keycloak/tree/master/adapter-wildfly),  but with a more up to date Wildfly base image
  - Uses the [JBoss CLI](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.0/html-single/management_cli_guide/index) instead of [sed](https://www.gnu.org/software/sed/manual/sed.html) to modify the "standalone.xml".
- **Use [Eclipse MicroProfile Health](https://github.com/eclipse/microprofile-health/)** with the necessary [WildFly Extension](https://github.com/jmesnil/wildfly-microprofile-health)
- **Add a PostgreSQL data source on first startup (OPTIONAL)**
  - For security reasons the password for a JEE data source should not be included directly in a Docker image
  - It's better to configure the data source on first startup of the Wildfly Docker image
  - Define PostgreSQL version and download JDBC driver on first startup
  - Allows passing all necessary data as environment variables
- **Wildfly to logstash using the [WildFly JSON Formatter](https://logging.paluch.biz/examples/wildfly-json.html)**  
  - Installs the necessary configuration on first startup of the Wildfly Docker image
- *FEATURE BROKEN* (See [ELY-1705](https://issues.jboss.org/browse/ELY-1705)) **Protect the Wildfly Management Console with Keycloak (OPTIONAL)**
  - Installs the necessary configuration on first startup of the Wildfly Docker image
  - Allows passing all necessary data as environment variables  

As a standard feature of Wildfly 14+ you can also use:

- **MicroProfile Config Feature** (See [Wildfly Admin Guide MicroProfile Config SmallRye](http://docs.wildfly.org/14/Admin_Guide.html#MicroProfile_Config_SmallRye))
- **MicroProfile OpenTracing Feature** (See [Wildfly Admin Guide MicroOrofile OpenTracing SmallRye](http://docs.wildfly.org/14/Admin_Guide.html#MicroProfile_OpenTracing%20SmallRye))

## TODO

- Support for [Eclipse Microprofile Metrics](https://github.com/eclipse/microprofile-metrics)
- Support for [Eclipse Microprofile Fault Tolerance](https://github.com/eclipse/microprofile-fault-tolerance)

## Usage

The following features are statically included in the Docker image (always enabled):

- Keycloak Adapter
- MicroProfile Health

Examples on how to run the container with different configurations:

- [Minimal startup](#minimal-startup)
- [Startup with management console](#startup-with-management-console)
- [Startup with PostgreSQL data source](#startup-with-postgresql-data-source)
- [Startup with all features](#startup-with-all-features)


### Minimal startup 
This configuration has only the features that are statically included in the image.

Features
- No management console
- No data source
- No Logstash

```
docker run -p 8080:8080 -it fuinorg/wildfly-keycloak-microprofile
```

### Startup with management console 
This configures Wildfly's "standalone.xml" at first startup of the Docker container to secure the management console with Keycloak.  

Features
- Management console connected to Keycloak
- No data source
- No Logstash

```
docker run \
  -p 8080:8080 \
  -p 9990:9990 \
  -e INSTALL_WILDFLY_MGMT_SERVICE=true \
  -e KEYCLOAK_SERVER_URL="http://localhost:8088/auth" \
  -e KEYCLOAK_REALM_PUBLIC_KEY="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmAFTCSVf7onYIK76usq9sF6hsLvmzarXYZOgJPsD6dsPzvk9e+09jbB96LeFg+S88gSTRwuxLYyMjSe6+zUCThNnX785momaxqs9VxjAXG0qkmpx1a/iD5RMdrsMfDwBZwcYiJtPncC5g9dtN0C0dMckLRUsg1zuQ5KmiJZQIGtse7BFwbtwYAhmYeYhJSqdS6rYdf/8gRLpHU4StRAjU+/dkDXJuXiXMBy65LfAX+SpQtpgKpcFK0u8FA9WsB5x4OeqYe+cyUUbsQe2gq7hm/iLVEOHYg+Xk+23jpFBinbRIjjveDf6IYkde4PUX7Y3ZRuTiD48TnohtwMK5RZpVwIDAQAB" \
  -it \
  fuinorg/wildfly-keycloak-microprofile \
  -b 0.0.0.0 \
  -bmanagement 0.0.0.0
```
**CAUTION**: The KEYCLOAK_REALM_PUBLIC_KEY is just an example - See [Protecting Wildfly Adminstration Console With Keycloak](https://docs.jboss.org/author/display/WFLY/Protecting+Wildfly+Adminstration+Console+With+Keycloak) on how to obtain a public key of wildfly-infra realm. The KEYCLOAK_SERVER_URL also depends on where your Keycloak server is running.

### Startup with PostgreSQL data source
This will add a new PostgreSQL data source to Wildfly's "standalone.xml" at first startup of the Docker container. 

Features
- No management console
- Configure a PostgreSQL data source
- No Logstash

```
docker run \
  -p 8080:8080 \
  -e INSTALL_POSTGRES=true \
  -e POSTGRES_VERSION=42.2.5 \
  -e POSTGRES_DATASOURCE=MYDS \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_USER=myuser \
  -it \
  fuinorg/wildfly-keycloak-microprofile
```

### Startup with all features 
This configures Wildfly's "standalone.xml" at first startup of the Docker container to secure the management console with Keycloak and adds a new PostgreSQL data source. 

Features
- Management console connected to Keycloak
- Configure a PostgreSQL data source
- Wildfly to Logstash

```
docker run \
  -p 8080:8080 \
  -p 9990:9990 \
  -e INSTALL_POSTGRES=true \
  -e POSTGRES_VERSION=42.2.5 \
  -e POSTGRES_DATASOURCE=MYDS \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_USER=myuser \
  -e INSTALL_WILDFLY_MGMT_SERVICE=true \
  -e INSTALL_JSON_LOG_FORMAT=true \
  -e KEYCLOAK_SERVER_URL="http://localhost:8088/auth" \
  -e KEYCLOAK_REALM_PUBLIC_KEY="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmAFTCSVf7onYIK76usq9sF6hsLvmzarXYZOgJPsD6dsPzvk9e+09jbB96LeFg+S88gSTRwuxLYyMjSe6+zUCThNnX785momaxqs9VxjAXG0qkmpx1a/iD5RMdrsMfDwBZwcYiJtPncC5g9dtN0C0dMckLRUsg1zuQ5KmiJZQIGtse7BFwbtwYAhmYeYhJSqdS6rYdf/8gRLpHU4StRAjU+/dkDXJuXiXMBy65LfAX+SpQtpgKpcFK0u8FA9WsB5x4OeqYe+cyUUbsQe2gq7hm/iLVEOHYg+Xk+23jpFBinbRIjjveDf6IYkde4PUX7Y3ZRuTiD48TnohtwMK5RZpVwIDAQAB" \
  -it \
  fuinorg/wildfly-keycloak-microprofile \
  -b 0.0.0.0 \
  -bmanagement 0.0.0.0
```
**CAUTION**: The KEYCLOAK_REALM_PUBLIC_KEY is just an example - See [Protecting Wildfly Adminstration Console With Keycloak](https://docs.jboss.org/author/display/WFLY/Protecting+Wildfly+Adminstration+Console+With+Keycloak) on how to obtain a public key of wildfly-infra realm. The KEYCLOAK_SERVER_URL also depends on where your Keycloak server is running.


## Building the Docker image

```
docker build -t fuinorg/wildfly-keycloak-microprofile .
```
