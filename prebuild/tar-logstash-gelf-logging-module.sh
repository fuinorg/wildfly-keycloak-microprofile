#!/bin/sh

# Downloads a version from https://repo1.maven.org/maven2/biz/paluch/logging/logstash-gelf
# and creates a tar file from it that can be installed directly into Wildfly 14 

logstashGelfVersion=1.12.0
currentDir=$(pwd)
downloadPath=$currentDir
basePath=$downloadPath/modules/system/layers/base
zipFile=logstash-gelf-$logstashGelfVersion-logging-module.zip
tarGzFile=logstash-gelf-$logstashGelfVersion-logging-module.tar.gz

if [ -f $downloadPath/$tarGzFile ] ; then
  echo "Skip logstash-gelf-logging task..."
else
echo "Execute logstash-gelf-logging task... (tar.gz file already exists)"
  mkdir -p $basePath
  cd $basePath
  curl -L https://repo1.maven.org/maven2/biz/paluch/logging/logstash-gelf/$logstashGelfVersion/$zipFile -o $zipFile
  unzip $zipFile
  rm $zipFile
  mv logstash-gelf-$logstashGelfVersion/biz biz
  rm -r logstash-gelf-$logstashGelfVersion
  cd $downloadPath
  tar czf $tarGzFile modules
  rm -r $downloadPath/modules
  cd $currentDir
fi
