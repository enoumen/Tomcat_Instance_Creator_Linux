#!/bin/sh

#########################Create_Instance#######################
#create_instance.sh script to create a new tomcat instance on Linux
#By Etienne Noumen
#Date: 2012/08/30
##############################################################


Instance_Name=$1
BASE="/u01/apache_tomcat_group/Instances"
LOGS_BASE="/u01/logs"
TOMCAT_LOGS="/u01/logs/$1/tomcat"
LOG4J_LOGS="/u01/logs/$1/log4j"
TOMCAT_BASE="/u00/softwares/tomcat/apache-tomcat-6.0.35"
JAVA_BASE="/u00/softwares/java/jdk1.6.0_35"
COMMON_LIB="/u01/apache_tomcat_group/common/lib"
TEMPLATES="/u01/apache_tomcat_group/templates"
DEPLOY="/u01/apache_tomcat_group/deploy"
OWNER="TOMCAT_ACCOUNT"
GROUP="TOMCAT_GROUP"

regex="([a-zA-Z][a-zA-Z][a-zA-Z]+)_(PDEV|DEV|PTRN|TRN|PUAT|UAT|PRD|SYT|PTST|TST)_([0-9][0-9][0-9])"
CHECK=$(echo $Instance_Name | egrep -x $regex)
if [[ "$?" -eq 0 ]]
then 
   INSTANCE_HOME=$BASE/$Instance_Name
   #Check if New Instance Directory is empty
   for i in $INSTANCE_HOME/*
   do
     if [ -e $i ] && [ $(echo $?) -eq "0" ]
     then
       echo "The directory $INSTANCE_HOME is not empty.\nClear the $INSTANCE_HOME directory and rerun the script."
       exit
     fi
   done
 
   #Check if new Logs Directory is not empty
   LOGS_HOME=$LOGS_BASE/$Instance_Name
   for i in $LOGS_HOME/*
   do
     if [ -e $i ] && [ $(echo $?) -eq "0" ]
     then
       echo "The directory  $LOGS_HOME is not empty. Clear the $LOGS_HOME directory and rerun the script." 
       exit
     fi
   done
   # All cleared: Creating Instance ....
   echo "Instance Name is $Instance_Name"
   #Create Instance Folder
   mkdir $BASE/$Instance_Name
   
   #Create Logs Folder
   
   mkdir $LOGS_BASE/$Instance_Name
   mkdir $TOMCAT_LOGS
   mkdir $LOG4J_LOGS
   cd $BASE/$Instance_Name
   
   # Create deploy folder
   mkdir $DEPLOY/$Instance_Name
   mkdir $DEPLOY/$Instance_Name/notifications
   echo "admin@test.ca" > $DEPLOY/$Instance_Name/notifications/email.txt 
   # Create sym links
   ln -s $TOMCAT_LOGS logs 
   ln -s $LOG4J_LOGS log4j
   ln -s $TOMCAT_BASE tomcat 
   ln -s $JAVA_BASE java

   #Copy Base folders from tomcat
   cp -r $TOMCAT_BASE/conf $BASE/$Instance_Name/
   cp -r $TOMCAT_BASE/webapps $BASE/$Instance_Name/
   cp -r $TOMCAT_BASE/temp $BASE/$Instance_Name/
   cp -r $TOMCAT_BASE/work $BASE/$Instance_Name/

   #Create backup folders
   mkdir $BASE/$Instance_Name/_archives


   #log4j.properties 
   mkdir $BASE/$Instance_Name/lib
   cd $BASE/$Instance_Name/lib
   ln -s $COMMON_LIB/log4j.properties log4j.properties
   cd $BASE/$Instance_Name/lib
   
   # Create jsvc.properties
   Server_Name=`hostname`
   sed "s/Instance_Name/$Instance_Name/g" $TEMPLATES/jsvc.properties > $BASE/$Instance_Name/jsvc.properties_temp
   sed "s/Server_Name/$Server_Name/g" $BASE/$Instance_Name/jsvc.properties_temp > $BASE/$Instance_Name/jsvc.properties
   rm -f $BASE/$Instance_Name/jsvc.properties_temp
   
   #Backup server.xml and enter new port number

   echo "Instance Name is $Instance_Name."
   PORT_FIRST_3_DIGITS=`echo $Instance_Name | awk '{ print substr($0, length($0) - 2, length($0) ) }'`
   HTTP_PORT="$PORT_FIRST_3_DIGITS""00"
   SSL_PORT="$PORT_FIRST_3_DIGITS""01"
   AJP_PORT="$PORT_FIRST_3_DIGITS""02"
   SHUTDOWN_PORT="$PORT_FIRST_3_DIGITS""03"
   echo "HTTP_PORT:$HTTP_PORT ; SSL_PORT:$SSL_PORT ; AJP_PORT:$AJP_PORT ; SHUTDOWN_PORT:$SHUTDOWN_PORT"
   
   cp $BASE/$Instance_Name/conf/server.xml $BASE/$Instance_Name/conf/server.xml.orig.`date +%Y%m%d%H%M%s`
   #Enter correct port number in server.xml
   sed "s/8080/$HTTP_PORT/g" $BASE/$Instance_Name/conf/server.xml > $BASE/$Instance_Name/conf/temp1.xml
   sed "s/8443/$SSL_PORT/g" $BASE/$Instance_Name/conf/temp1.xml > $BASE/$Instance_Name/conf/temp2.xml
   sed "s/8009/$AJP_PORT/g" $BASE/$Instance_Name/conf/temp2.xml  > $BASE/$Instance_Name/conf/temp3.xml
   sed "s/8005/$SHUTDOWN_PORT/g" $BASE/$Instance_Name/conf/temp3.xml > $BASE/$Instance_Name/conf/temp4.xml
   cp  $BASE/$Instance_Name/conf/temp4.xml  $BASE/$Instance_Name/conf/server.xml
   rm -f $BASE/$Instance_Name/conf/temp*.xml 
   
   #Enter correct  tomcat admin logn and password in tomcat-users.xml file
   awk 'NR>1{print buf}{buf = $0}' $BASE/$Instance_Name/conf/tomcat-users.xml > $BASE/$Instance_Name/conf/tomcat-users.xml.temp
   mv  $BASE/$Instance_Name/conf/tomcat-users.xml.temp $BASE/$Instance_Name/conf/tomcat-users.xml
   cat $TEMPLATES/tomcat_admin.txt >> $BASE/$Instance_Name/conf/tomcat-users.xml

   #Access Rights
   chown -R $OWNER:$GROUP $BASE/$Instance_Name
   chmod -R ug+rwx $BASE/$Instance_Name
   chmod -R o+x $BASE/$Instance_Name
   chown -R $OWNER:$GROUP $LOGS_BASE/$Instance_Name
   chmod -R ug+rwx $LOGS_BASE/$Instance_Name
   chmod -R o+x $LOGS_BASE/$Instance_Name
   chown -R $OWNER:$GROUP $DEPLOY
   chmod -R ug+rwx $DEPLOY/$Instance_Name

   #End of script
   echo "The Instance $Instance_Name was created successfully."

else
   echo "Enter the Instance Name as argument in the format ABC_ENV_123 and rerun the script"
   exit 
fi
