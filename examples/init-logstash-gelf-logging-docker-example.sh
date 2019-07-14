#!/bin/sh

# Start the docker image with shell to allow manual execution of Wildfly inside the container
# Inside the container type: 
# ./startup.sh -b 0.0.0.0

docker run -it --entrypoint /bin/bash \
 -e INSTALL_JSON_LOG_FORMAT=true \
 -e JSON_LOG_VERSION="1.1" \
 -e JSON_LOG_HOST="udp:localhost" \
 -e JSON_LOG_PORT="12201" \
 -e JSON_LOG_FACILITY="java-test" \
 -e JSON_LOG_FIELDS="Time, Severity,ThreadName,SourceClassName,SourceMethodName,SourceSimpleClassName,LoggerName,NDC,Server" \
 -e JSON_LOG_EXTRACT_STACK_TRACE=true \
 -e JSON_LOG_FILTER_STACK_TRACE=true \
 -e JSON_LOG_INCLUDE_LOG_MESSAGE_PARAMETERS=true \
 -e JSON_LOG_INCLUDE_LOCATION=true \
 -e JSON_LOG_MDC_PROFILING=true \
 -e JSON_LOG_TIMESTAMP_PATTERN="yyyy-MM-dd HH:mm:ss,SSSS" \
 -e JSON_LOG_ADDITIONAL_FIELDS="fieldName1=fieldValue1,fieldName2=fieldValue2" \
 -e JSON_LOG_ADDITIONAL_FIELD_TYPES="fieldName1=String,fieldName2=Double,fieldName3=Long" \
 -e JSON_LOG_MDC_FIELDS="mdcField1,mdcField2" \
 -e JSON_LOG_DYNAMIC_MDC_FIELDS="mdc.*,(mdc|MDC)fields" \
 -e JSON_LOG_INCLUDE_FULL_MDC=false \
 fuinorg/wildfly-keycloak-microprofile