#!/bin/sh

Action=$1
Instance_Name=$2
BASE="/u01/apache_tomcat_group/Instances"
source $BASE/$Instance_Name/jsvc.properties
echo "INSTANCE_HOME: $INSTANCE_HOME" >&2
echo "JAVA_HOME: $JAVA_HOME" >&2
echo "JAVA_OPTS: $JAVA_OPTS" >&2
echo "CATALINA_HOME: $CATALINA_HOME" >&2
echo "CATALINA_BASE: $CATALINA_BASE" >&2
echo "CATALINA_OPTS: $CATALINA_OPTS" >&2

# Export Variables

export JAVA_HOME=$JAVA_HOME
export JAVA_OPTS=$JAVA_OPTS
export CATALINA_HOME=$CATALINA_HOME
export CATALINA_BASE=$CATALINA_BASE
export CATALINA_OPTS=$CATALINA_OPTS

# Start/Stop server

$CATALINA_HOME/bin/catalina.sh $Action
