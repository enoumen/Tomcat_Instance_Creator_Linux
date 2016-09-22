#!/bin/bash

PID=`ps -ef | grep BW_DEV_135 | grep java | grep tomcat | grep start | gawk '{print $2}'`
if [ -z "$PID" ]; then
   echo " BW_DEV_135 is not running."
else
  echo "$PID"
fi
