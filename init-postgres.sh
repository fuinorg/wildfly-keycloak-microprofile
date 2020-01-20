#!/bin/sh

# Define parameters
wildflyHome=
postgresHost=
postgresPort=
postgresDB=
postgresVersion=
postgresDatasource=
postgresUser=
postgresPassword=

# Print usage
usage() {
    echo ""
    echo "Adds PostgreSQL module, subsystem and data source to Wildfly."
    echo "Will only be executed once to avoid duplicate entries or errors."
    echo ""
    echo "REQUIRED:"
    echo "--wildflyHome=/opt/jboss/wildfly"
    echo "--postgresVersion=42.2.5"
    echo "--postgresDB=postgres"
    echo "--postgresDatasource=MYDS"
    echo "--postgresPassword=secret"
    echo ""
    echo "OPTIONAL:"
    echo "-h --help"
    echo "--postgresHost=localhost (defaults 'localhost')"
    echo "--postgresPort=5432 (defaults to 5432)"
    echo "--postgresUser=myds (defaults to lower case 'postgresDatasource')"
    echo ""
}

RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --wildflyHome)
            wildflyHome=$VALUE
            ;;
        --postgresHost)
            postgresHost=$VALUE
            ;;
        --postgresPort)
            postgresPort=$VALUE
            ;;
        --postgresDB)
            postgresDB=$VALUE
            ;;
        --postgresVersion)
            postgresVersion=$VALUE
            ;;
        --postgresDatasource)
            postgresDatasource=$VALUE
            ;;
        --postgresUser)
            postgresUser=$VALUE
            ;;
        --postgresPassword)
            postgresPassword=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

# Verify that all mandatory parameters are set
errorMessage=

if [ -z "$wildflyHome" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--wildflyHome${NC} is missing"
fi
if [ -z "$postgresHost" ];  then
    postgresHost="localhost"
fi
if [ -z "$postgresPort" ];  then
    postgresPort="5432"
fi
if [ -z "$postgresDB" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--postgresDB${NC} is missing"
fi
if [ -z "$postgresVersion" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--postgresVersion${NC} is missing"
fi
if [ -z "$postgresDatasource" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--postgresDatasource${NC} is missing"
fi
if [ -z "$postgresPassword" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--postgresPassword${NC} is missing"
fi

if [ ! -z "$errorMessage" ];  then
	echo "${errorMessage}"
	usage
    exit 2
fi

# --- Start installation ---

# This file prevents multiple installations
initPostgresDoneFile=$wildflyHome/init-postgres.done
if [ -f $initPostgresDoneFile ] ; then
    echo "Skip configuration (was already done)..."
    exit 0
fi
touch $initPostgresDoneFile

# Download PostgreSQL JAR file
postgresJarFile=$wildflyHome/postgresql-$postgresVersion.jar
curl -L -o $postgresJarFile https://repo1.maven.org/maven2/org/postgresql/postgresql/$postgresVersion/postgresql-$postgresVersion.jar

# Fallback for usage outside of Docker container
postgresCliFile=$wildflyHome/bin/postgres-install-offline.cli
if [ ! -f $postgresCliFile ] ; then
	cp postgres-install-offline.cli $postgresCliFile
fi

# Create a file with all variables to pass to JBoss CLI
wildflyCliPropertiesFile=$wildflyHome/patch-wildfly.properties
echo "Create $wildflyCliPropertiesFile..."
rm -f $wildflyCliPropertiesFile
echo "postgresHost=$postgresHost" >> $wildflyCliPropertiesFile
echo "postgresPort=$postgresPort" >> $wildflyCliPropertiesFile
echo "postgresDB=$postgresDB" >> $wildflyCliPropertiesFile
echo "postgresJarFile=$postgresJarFile" >> $wildflyCliPropertiesFile
echo "postgresDatasource=$postgresDatasource" >> $wildflyCliPropertiesFile
echo "postgresUser=$postgresUser" >> $wildflyCliPropertiesFile
echo "postgresPw=$postgresPassword" >> $wildflyCliPropertiesFile
echo "" >> $wildflyCliPropertiesFile

# Give some nice feedback
echo "wildflyHome=$wildflyHome";
echo "postgresHost=$postgresHost";
echo "postgresPort=$postgresPort";
echo "postgresDB=$postgresDB";
echo "postgresVersion=$postgresVersion";
echo "postgresDatasource=$postgresDatasource";
echo "postgresUser=$postgresUser";
echo "postgresPassword=***";
echo "postgresJarFile=$postgresJarFile"

# Execute JBoss CLI script
sed -i "s/<resolve-parameter-values>false<\/resolve-parameter-values>/<resolve-parameter-values>true<\/resolve-parameter-values>/" $wildflyHome/bin/jboss-cli.xml
echo "Install PostgreSQL..."
$wildflyHome/bin/jboss-cli.sh --properties=$wildflyCliPropertiesFile --file="$postgresCliFile"

# Cleanup
rm -f $postgresJarFile
rm -f $wildflyCliPropertiesFile
rm -rf $wildflyHome/standalone/configuration/standalone_xml_history/current/*
