#!/bin/sh
. ./getopts_long.sh
. ./utils.sh

# Define parameters with defaults
wildflyHome=
lglHost="udp:localhost"
lglPort=12201
lglFacility=
lglVersion="1.0"
lglFields="Time, Severity,ThreadName,SourceClassName,SourceMethodName,SourceSimpleClassName,LoggerName,NDC,Server"
lglExtractStackTrace=true
lglFilterStackTrace=true
lglIncludeLogMessageParameters=true
lglIncludeLocation=true
lglMdcProfiling=false
lglTimestampPattern="yyyy-MM-dd HH:mm:ss,SSSS"
lglAdditionalFields=
lglAdditionalFieldTypes=
lglMdcFields=
lglDynamicMdcFields=
lglIncludeFullMdc=false

# Print usage
usage() {
	echo ""
    echo "Adds logstash-gelf JSON support module to Wildfly."
    echo "Will only be executed once to avoid duplicate entries or errors."
    echo ""
    echo "REQUIRED:"
    echo "--wildflyHome=\"/opt/jboss/wildfly\""
    echo ""
    echo "OPTIONAL:"
    echo "-h --help"
    echo "--lglVersion=\"1.0\""
    echo "--lglHost=\"localhost\""
    echo "--lglPort=\"12201\""
    echo "--lglFacility=\"java-test\""
    echo "--lglFields=\"Time,Severity,ThreadName,SourceClassName,SourceMethodName,SourceSimpleClassName,LoggerName,NDC\""
    echo "--lglExtractStackTrace=true"
    echo "--lglFilterStackTrace=true"
    echo "--lglIncludeLogMessageParameters=true"
    echo "--lglIncludeLocation=true"
    echo "--lglMdcProfiling=true"
    echo "--lglTimestampPattern=\"yyyy-MM-dd HH:mm:ss,SSSS\""
    echo "--lglAdditionalFields=\"fieldName1=fieldValue1,fieldName2=fieldValue2\""
    echo "--lglAdditionalFieldTypes=\"fieldName1=String,fieldName2=Double,fieldName3=Long\""
    echo "--lglMdcFields=\"mdcField1,mdcField2\""
    echo "--lglDynamicMdcFields=\"mdc.*,(mdc|MDC)fields\""
    echo "--lglIncludeFullMdc=true"
    echo ""
}

# Parse arguments
OPTLIND=1
while getopts_long :sf:b::vh opt \
  wildflyHome 1 \
  lglVersion 1 \
  lglHost 1 \
  lglPort 1 \
  lglFacility 1 \
  lglFields 1 \
  lglExtractStackTrace 1 \
  lglFilterStackTrace 1 \
  lglIncludeLogMessageParameters 1 \
  lglIncludeLocation 1 \
  lglMdcProfiling 1 \
  lglTimestampPattern 1 \
  lglAdditionalFields 1 \
  lglAdditionalFieldTypes 1 \
  lglMdcFields 1 \
  lglDynamicMdcFields 1 \
  lglIncludeFullMdc 1 \
  help 0 "" "$@"
do
  case "$opt" in
    h|help) usage; exit 0;;
    wildflyHome) wildflyHome=$OPTLARG;;
    lglVersion) lglVersion=$OPTLARG;;
    lglHost) lglHost=$OPTLARG;;
    lglPort) lglPort=$OPTLARG;;
    lglFacility) lglFacility=$OPTLARG;;
    lglFields) lglFields=$OPTLARG;;
    lglExtractStackTrace) lglExtractStackTrace=$OPTLARG;;
    lglFilterStackTrace) lglFilterStackTrace=$OPTLARG;;
    lglIncludeLogMessageParameters) lglIncludeLogMessageParameters=$OPTLARG;;
    lglIncludeLocation) lglIncludeLocation=$OPTLARG;;
    lglMdcProfiling) lglMdcProfiling=$OPTLARG;;
    lglTimestampPattern) lglTimestampPattern=$OPTLARG;;
    lglAdditionalFields) lglAdditionalFields=$OPTLARG;;
    lglAdditionalFieldTypes) lglAdditionalFieldTypes=$OPTLARG;;
    lglMdcFields) lglMdcFields=$OPTLARG;;
    lglDynamicMdcFields) lglMdcFields=$OPTLARG;;
    lglIncludeFullMdc) lglMdcFields=$OPTLARG;;
    :) printf >&2 '%s: %s\n' "${0##*/}" "$OPTLERR"
       usage
       exit 1;;
  esac
done
shift "$(($OPTLIND - 1))"

# Verify that all mandatory parameters are set

fields= # Contains later missing fields
assertFieldExists wildflyHome $wildflyHome
if [ ! -z "$fields" ];  then
	echo ""
    echo "Missing mandatory parameter(s): ${RED}${fields}${NC}"
    usage
    exit 2
fi

# --- Start installation ---

# This file prevents multiple installations
initLglDoneFile=$wildflyHome/init-lgl.done
if [ -f $initLglDoneFile ] ; then
    echo "Skip configuration (was already done)..."
    exit 0
fi
touch $initLglDoneFile

# Create a CLI file to execute with JBoss CLI
wildflyCliFile=$wildflyHome/bin/logstash-gelf-logging-offline.cli
echo "Create $wildflyCliFile..."
rm -f $wildflyCliFile

echo "embed-server --server-config=\${server.config:standalone.xml}" >> $wildflyCliFile
echo "" >> $wildflyCliFile
echo "/subsystem=logging/custom-formatter=JsonFormatter/:add(module=biz.paluch.logging,class=biz.paluch.logging.gelf.wildfly.WildFlyJsonFormatter,properties={ \\" >> $wildflyCliFile
echo "       version=\"$lglVersion\", \\" >> $wildflyCliFile
if [ ! -z "$lglFacility" ];  then
    echo "       facility=\"$lglFacility\", \\" >> $wildflyCliFile
fi
echo "       fields=\"$lglFields\", \\" >> $wildflyCliFile
echo "       extractStackTrace=$lglExtractStackTrace, \\" >> $wildflyCliFile
echo "       filterStackTrace=$lglFilterStackTrace, \\" >> $wildflyCliFile
echo "       includeLogMessageParameters=$lglIncludeLogMessageParameters, \\" >> $wildflyCliFile
echo "       includeLocation=$lglIncludeLocation, \\" >> $wildflyCliFile
echo "       mdcProfiling=$lglMdcProfiling, \\" >> $wildflyCliFile
echo "       timestampPattern=\"$lglTimestampPattern\", \\" >> $wildflyCliFile
if [ ! -z "$lglAdditionalFields" ];  then
    echo "       additionalFields=\"$lglAdditionalFields\", \\" >> $wildflyCliFile
fi
if [ ! -z "$lglAdditionalFieldTypes" ];  then
    echo "       additionalFieldTypes=\"$lglAdditionalFieldTypes\", \\" >> $wildflyCliFile
fi
if [ ! -z "$lglMdcFields" ];  then
    echo "       mdcFields=\"$lglMdcFields\", \\" >> $wildflyCliFile
fi
if [ ! -z "$lglDynamicMdcFields" ];  then
    echo "       dynamicMdcFields=\"$lglDynamicMdcFields\", \\" >> $wildflyCliFile
fi
if [ ! -z "$lglIncludeFullMdc" ];  then
    echo "       includeFullMdc=$lglIncludeFullMdc, \\" >> $wildflyCliFile
fi
echo "}) " >> $wildflyCliFile
echo "" >> $wildflyCliFile
echo "/subsystem=logging/file-handler=JsonLog/:add(file={\"relative-to\"=>\"jboss.server.log.dir\", path=server.json}, level=ALL,named-formatter=JsonFormatter)" >> $wildflyCliFile
echo "" >> $wildflyCliFile
echo "/subsystem=logging/root-logger=ROOT/:add-handler(name=JsonLog)" >> $wildflyCliFile
echo "" >> $wildflyCliFile

# Give some nice feedback
echo "Created $wildflyCliFile"
echo "------------------------"
cat $wildflyCliFile
echo "------------------------"

# Execute JBoss CLI script
echo "Install logstash-gelf support..."
$wildflyHome/bin/jboss-cli.sh --file="$wildflyCliFile"

# Cleanup
rm -rf $wildflyHome/standalone/configuration/standalone_xml_history/current/*
