#!/bin/sh
. ./utils.sh

# Displays error message and exits if 'fields' is not empty.
assertFieldsEmpty() {
	if [ ! -z "$fields" ];  then
	    echo "Missing environment variable(s): ${fields} - Please pass with '-e NAME=VALUE'"
	    exit 1
	fi
}


if [ "$INSTALL_POSTGRES" = "true" ];  then
	
	# Verify all mandatory environment variables are provided
	fields= # Contains later missing fields
	assertFieldExists POSTGRES_VERSION $POSTGRES_VERSION
	assertFieldExists POSTGRES_DATASOURCE $POSTGRES_DB
	assertFieldExists POSTGRES_DATASOURCE $POSTGRES_DATASOURCE
	assertFieldExists POSTGRES_PASSWORD $POSTGRES_PASSWORD
	assertFieldsEmpty

	# Special handling for some variables
	if [ -z "$POSTGRES_USER" ];  then
	    POSTGRES_USER=$(echo $postgresDatasource | tr '[:upper:]' '[:lower:]')
	fi

	# Create list only containing the non-empty arguments
    arg_list= # Contains later list with all args
    addArg postgresVersion $POSTGRES_VERSION 
    addArg postgresDB $POSTGRES_DB 
    addArg postgresDatasource $POSTGRES_DATASOURCE 
    addArg postgresPassword $POSTGRES_PASSWORD 
    addArg postgresUser $POSTGRES_USER 
    addArg postgresHost $POSTGRES_HOST 
    addArg postgresPort $POSTGRES_PORT

    # Call installer script
	./init-postgres.sh --wildflyHome=$JBOSS_HOME $arg_list
	
fi

if [ "$INSTALL_WILDFLY_MGMT_SERVICE" = "true" ];  then

	# Verify all mandatory environment variables are provided
	fields= # Contains later missing fields
	assertFieldExists KEYCLOAK_SERVER_URL $KEYCLOAK_SERVER_URL
	assertFieldExists KEYCLOAK_REALM_PUBLIC_KEY $KEYCLOAK_REALM_PUBLIC_KEY
	assertFieldsEmpty

    # Call installer script
	./init-wildfly-mgmt-services.sh --wildflyHome=$JBOSS_HOME --keycloakServerUrl=$KEYCLOAK_SERVER_URL --keycloakRealmPublicKey=$KEYCLOAK_REALM_PUBLIC_KEY

fi

if [ "$INSTALL_JSON_LOG_FORMAT" = "true" ];  then

	# Create list only containing the non-empty arguments
    arg_list= # Contains later list with all args
    addArg lglVersion $JSON_LOG_VERSION
    addArg lglHost $JSON_LOG_HOST
    addArg lglPort $JSON_LOG_PORT
    addArg lglFacility $JSON_LOG_FACILITY
    addArg lglFields $JSON_LOG_FIELDS
    addArg lglExtractStackTrace $JSON_LOG_EXTRACT_STACK_TRACE
    addArg lglFilterStackTrace $JSON_LOG_FILTER_STACK_TRACE
    addArg lglIncludeLogMessageParameters $JSON_LOG_INCLUDE_LOG_MESSAGE_PARAMETERS
    addArg lglIncludeLocation $JSON_LOG_INCLUDE_LOCATION
    addArg lglMdcProfiling $JSON_LOG_MDC_PROFILING
    addArg lglTimestampPattern $JSON_LOG_TIMESTAMP_PATTERN
    addArg lglAdditionalFields $JSON_LOG_ADDITIONAL_FIELDS
    addArg lglAdditionalFieldTypes $JSON_LOG_ADDITIONAL_FIELD_TYPES
    addArg lglMdcFields $JSON_LOG_MDC_FIELDS
    addArg lglDynamicMdcFields $JSON_LOG_DYNAMIC_MDC_FIELDS
    addArg lglIncludeFullMdc $JSON_LOG_INCLUDE_FULL_MDC

    # Call installer script
	./init-logstash-gelf-logging.sh --wildflyHome=$JBOSS_HOME $arg_list

fi

echo "Starting Wildfly with arguments: $@"

./bin/standalone.sh "$@"
exit $?
