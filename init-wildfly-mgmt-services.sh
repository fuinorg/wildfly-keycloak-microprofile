#!/bin/sh

# Define parameters
wildflyHome=
keycloakVersion=
keycloakServerUrl=
keycloakRealmPublicKey=

# Print usage
usage() {
    echo ""
    echo "Protecting Wildfly Adminstration Console With Keycloak."
    echo "Will only be executed once to avoid duplicate entries or errors."
    echo ""
    echo "REQUIRED:"
    echo "--wildflyHome=/opt/jboss/wildfly"
    echo "--keycloakVersion=4.5.0.Final"
    echo "--keycloakServerUrl=http://localhost:8180/auth"
    echo "--keycloakRealmPublicKey=..."
    echo ""
    echo "OPTIONAL:"
    echo "-h --help"
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
        --keycloakVersion)
            keycloakVersion=$VALUE
            ;;
        --keycloakServerUrl)
            keycloakServerUrl=$VALUE
            ;;
        --keycloakRealmPublicKey)
            keycloakRealmPublicKey=$VALUE
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
if [ -z "$keycloakVersion" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--keycloakVersion${NC} is missing"
fi
if [ -z "$keycloakServerUrl" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--keycloakServerUrl${NC} is missing"
fi
if [ -z "$keycloakRealmPublicKey" ];  then
    errorMessage="${errorMessage}\nArgument ${RED}--keycloakRealmPublicKey${NC} is missing"
fi
if [ ! -z "$errorMessage" ];  then
	echo "${errorMessage}"
	usage
    exit 2
fi

# --- Start installation ---

# This file prevents multiple installations
initWildflyMgmtService=$wildflyHome/init-wildfly-mgmt-services.done
if [ -f $initWildflyMgmtService ] ; then
    echo "Skip configuration (was already done)..."
    exit 0
fi
touch $initWildflyMgmtService

cliFile=$wildflyHome/bin/protect-wildfly-mgmt-services.cli

# Fallback for usage outside of Docker container
if [ ! -f $cliFile ] ; then
	baseDir=$(pwd)
	cd $wildflyHome
    sed -i "s/<resolve-parameter-values>false<\/resolve-parameter-values>/<resolve-parameter-values>true<\/resolve-parameter-values>/" $wildflyHome/bin/jboss-cli.xml
    curl -L https://downloads.jboss.org/keycloak/$keycloakVersion/adapters/keycloak-oidc/keycloak-wildfly-adapter-dist-$keycloakVersion.tar.gz | tar zx
    curl -L https://downloads.jboss.org/keycloak/$keycloakVersion/adapters/saml/keycloak-saml-wildfly-adapter-dist-$keycloakVersion.tar.gz | tar zx
    bin/jboss-cli.sh --file="bin/adapter-elytron-install-offline.cli"
	cd $baseDir
	cp protect-wildfly-mgmt-services.cli $cliFile
fi

# Create a file with all variables to pass to JBoss CLI
cliPropertiesFile=$wildflyHome/patch-wildfly.properties
echo "Create $cliPropertiesFile..."
rm -f $cliPropertiesFile
echo "keycloakServerUrl=$keycloakServerUrl" >> $cliPropertiesFile
echo "keycloakRealmPublicKey=$keycloakRealmPublicKey" >> $cliPropertiesFile
echo "" >> $cliPropertiesFile

# Give some nice feedback
echo "wildflyHome=$wildflyHome"
echo "keycloakServerUrl=$keycloakServerUrl"
echo "keycloakRealmPublicKey=$keycloakRealmPublicKey"

# Execute JBoss CLI script
echo "Protect Wildfly adminstration console with Keycloak..."
$wildflyHome/bin/jboss-cli.sh --properties="$cliPropertiesFile" --file="$cliFile"

# Cleanup
# rm -f $cliPropertiesFile
rm -rf $wildflyHome/standalone/configuration/standalone_xml_history/current/*
