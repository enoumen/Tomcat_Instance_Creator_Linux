#!/bin/sh

#App Name List
App_List_Path="/u01/apache_tomcat_group/Instances"
App_List=`ls -l --time-style="long-iso" $App_List_Path | egrep '^d' | gawk '{print $8}'`

# Stop all servers
for App_Name in ${App_List[@]}
do
  #echo "Stopping $App_Name application...."
  #/u01/bin/tomcat_server.sh stop $App_Name
  #sleep 5
  ps -ef | grep $App_Name | grep java | grep tomcat | grep start > /dev/null
  if [ $? -eq 0 ]; then
    /u01/bin/tomcat_server.sh stop $App_Name > /dev/null
    sleep 2
    PID=`ps -ef | grep $App_Name | grep java | grep tomcat | grep start | gawk '{print $2}'`
    if [ -z "$PID" ]; then
       echo "$App_Name is not running."
    else 
      kill -9 $PID
      echo "$App_Name is not running."
    fi 
    
  else
    echo "$App_Name is not running."
  fi
done

