#!/bin/sh

# Patch a local version of Wildfly
# You need to adjust the "wildflyHome" variable below to point to the right directory

./init-logstash-gelf-logging.sh \
  --wildflyHome="/home/developer/Downloads/wildfly-14.0.1.Final" \
  --lglVersion="1.1" \
  --lglHost="localhost" \
  --lglPort=12201 \
  --lglFacility="java-test" \
  --lglFields="Time, Severity,ThreadName,SourceClassName,SourceMethodName,SourceSimpleClassName,LoggerName,NDC,Server" \
  --lglExtractStackTrace=true \
  --lglFilterStackTrace=true \
  --lglIncludeLogMessageParameters=true \
  --lglIncludeLocation=true \
  --lglMdcProfiling=true \
  --lglTimestampPattern="yyyy-MM-dd HH:mm:ss,SSSS" \
  --lglAdditionalFields="fieldName1=fieldValue1,fieldName2=fieldValue2" \
  --lglAdditionalFieldTypes="fieldName1=String,fieldName2=Double,fieldName3=Long" \
  --lglMdcFields="mdcField1,mdcField2" \
  --lglDynamicMdcFields="mdc.*,(mdc|MDC)fields" \
  --lglIncludeFullMdc=true
