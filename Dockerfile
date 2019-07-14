FROM jboss/wildfly:16.0.0.Final
MAINTAINER fuin.org

# Environment variables to pass on RUN

ENV INSTALL_POSTGRES=false
ENV POSTGRES_VERSION=
ENV POSTGRES_HOST=
ENV POSTGRES_PORT=
ENV POSTGRES_DB=
ENV POSTGRES_DATASOURCE=
ENV POSTGRES_PASSWORD=
ENV POSTGRES_USER=

ENV INSTALL_WILDFLY_MGMT_SERVICE=false
ENV KEYCLOAK_SERVER_URL=
ENV KEYCLOAK_REALM_PUBLIC_KEY=

ENV INSTALL_JSON_LOG_FORMAT=false
ENV JSON_LOG_VERSION=
ENV JSON_LOG_HOST=
ENV JSON_LOG_PORT=
ENV JSON_LOG_FACILITY=
ENV JSON_LOG_FIELDS=
ENV JSON_LOG_EXTRACT_STACK_TRACE=
ENV JSON_LOG_FILTER_STACK_TRACE=
ENV JSON_LOG_INCLUDE_LOG_MESSAGE_PARAMETERS=
ENV JSON_LOG_INCLUDE_LOCATION=
ENV JSON_LOG_MDC_PROFILING=
ENV JSON_LOG_TIMESTAMP_PATTERN=
ENV JSON_LOG_ADDITIONAL_FIELDS=
ENV JSON_LOG_ADDITIONAL_FIELD_TYPES=
ENV JSON_LOG_MDC_FIELDS=
ENV JSON_LOG_DYNAMIC_MDC_FIELDS=
ENV JSON_LOG_INCLUDE_FULL_MDC=

# Internal variables
ARG KEYCLOAK_VERSION=6.0.1
ARG LOGSTASH_GELF_VERSION=1.12.0
ARG LOGSTASH_GELF_TAR_GZ=logstash-gelf-$LOGSTASH_GELF_VERSION-logging-module.tar.gz

# Copy files into container
COPY microprofile-health-smallrye-install-offline.cli $JBOSS_HOME/bin
COPY postgres-install-offline.cli $JBOSS_HOME/bin
COPY protect-wildfly-mgmt-services.cli $JBOSS_HOME/bin
COPY init-postgres.sh $JBOSS_HOME
COPY init-wildfly-mgmt-services.sh $JBOSS_HOME
COPY init-logstash-gelf-logging.sh $JBOSS_HOME
COPY prebuild/$LOGSTASH_GELF_TAR_GZ $JBOSS_HOME
COPY getopts_long.sh $JBOSS_HOME
COPY utils.sh $JBOSS_HOME
COPY startup.sh $JBOSS_HOME

WORKDIR $JBOSS_HOME

# Change owner/group of all files to jboss
USER root
RUN chown jboss:jboss bin/microprofile-health-smallrye-install-offline.cli \
 && chown jboss:jboss bin/postgres-install-offline.cli \
 && chown jboss:jboss bin/protect-wildfly-mgmt-services.cli \
 && chown jboss:jboss init-postgres.sh \
 && chown jboss:jboss init-wildfly-mgmt-services.sh \
 && chown jboss:jboss init-logstash-gelf-logging.sh \
 && chown jboss:jboss $LOGSTASH_GELF_TAR_GZ \
 && chown jboss:jboss getopts_long.sh \
 && chown jboss:jboss utils.sh \
 && chown jboss:jboss startup.sh
USER jboss:jboss

# Basic setup
RUN sed -i "s/<resolve-parameter-values>false<\/resolve-parameter-values>/<resolve-parameter-values>true<\/resolve-parameter-values>/" bin/jboss-cli.xml \
 && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/adapters/keycloak-oidc/keycloak-wildfly-adapter-dist-$KEYCLOAK_VERSION.tar.gz | tar zx \
 && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/adapters/saml/keycloak-saml-wildfly-adapter-dist-$KEYCLOAK_VERSION.tar.gz | tar zx \
 && tar zxf $LOGSTASH_GELF_TAR_GZ \
 && bin/jboss-cli.sh --file="bin/adapter-install-offline.cli" \
 && bin/jboss-cli.sh --file="bin/microprofile-health-smallrye-install-offline.cli" \
 && rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/current/* 

ENTRYPOINT ["./startup.sh"]
CMD ["-b", "0.0.0.0"]
