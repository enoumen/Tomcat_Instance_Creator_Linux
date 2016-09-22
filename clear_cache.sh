#!/bin/sh

Instance_Name=$1
BASE="/u01/apache_tomcat_group/Instances"
source $BASE/$Instance_Name/jsvc.properties
echo "INSTANCE_HOME: $INSTANCE_HOME" >&2

if [  "$Instance_Name" !=  "" ]
then
    rm -r $BASE/$Instance_Name/work/Catalina/localhost
fi
