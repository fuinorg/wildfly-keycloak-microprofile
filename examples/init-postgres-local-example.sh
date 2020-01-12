#!/bin/sh

# Patch a local version of Wildfly
# You need to adjust the "wildflyHome" variable below to point to the right directory

./init-postgres.sh \
  --wildflyHome=/home/developer/Downloads/wildfly-14.0.1.Final \
  --postgresVersion=42.2.5 \
  --postgresDB=mydb \
  --postgresDatasource=MYDS \
  --postgresPassword=secret \
  --postgresUser=myuser \
  --postgresHost=localhost \
  --postgresPort=5432
