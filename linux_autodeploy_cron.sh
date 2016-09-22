#!/bin/sh

OWNER="TOMCAT.S"
GROUP="Admins"
BIN="/u01/bin"
DEPLOYER="$BIN/deploy.sh"
DEPLOY_PATH="/u01/apache_tomcat_group/deploy"
APP_LIST=( TEST_DEV_135 TIT_DEV_136 TOT_DEV_138 ) 
for Instance_Name in ${APP_LIST[@]};
do
    $DEPLOYER $Instance_Name &
done
RTN_CODE=$?
exit $RTN_CODE
