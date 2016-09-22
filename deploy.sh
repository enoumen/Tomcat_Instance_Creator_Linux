#!/bin/sh

Instance_Name=$1
BASE="/u01/apache_tomcat_group/Instances"
WEBAPPS="$BASE/$Instance_Name/webapps"
ARCHIVES="$BASE/$Instance_Name/_archives"
OWNER="TRANS.IMB-TOMCAT.S"
GROUP="appAdmins"
BIN="/u01/bin"
LOGS="/u01/logs/$Instance_Name"
TEMP="/u01/apache_tomcat_group/deploy/$Instance_Name"
NOTIFICATION_EMAIL_FILE="/u01/apache_tomcat_group/deploy/$Instance_Name/notifications/email.txt"
#Run script as Tomcat user

#  First check if there is a new file to deploy in the temp folder
autodeploy="no"
for newfile in `ls $TEMP`;
do 
   if [[ -f $TEMP/$newfile ]]
   then
      new_extension=`echo $newfile | awk -F . '{print $NF}'`
      new_warfile=$newfile
      if [[ $new_extension = "war" ]]; then
         echo "$new_warfile is a valid war file"
         # Stop Tomcat App server
         $BIN/tomcat_server.sh stop $Instance_Name
         sleep 10
         #ps -ef | grep $Instance_Name | awk '{print $2}' | xargs kill
         autodeploy="yes"
         break 
      else
         rm $TEMP/$newfile 
      fi
   fi
done
if [[ $autodeploy = "no" ]]; then 
    echo "There is no new war file to deploy"
    exit
fi 
#Backup all war files in webapps 
for file in `ls $WEBAPPS`; 
      do 
        if [[ -f $WEBAPPS/$file ]] 
        then 
           extension=`echo $file | awk -F . '{print $NF}'`
           expanded_folder=`echo $file | awk -F . '{print $1}'`
           #expanded_folder=`basename $file`
           #extension=${expanded_folder##*.}
           warfilename=$expanded_folder"."$extension
            
           if [[ $extension = "war" ]]; then
              
              # Backup old war file 
              mv $WEBAPPS/$warfilename $ARCHIVES/$warfilename-`date +%Y%m%d%H%M`
              rm -rf $WEBAPPS/$expanded_folder
           fi
         fi 
done
# Copy New warfiles from temp folder to webapps folder
mv $TEMP/*.war $WEBAPPS/
chmod -R ug+rwx $WEBAPPS/*.war
chown -R $OWNER:$GROUP $WEBAPPS/*
rm -f $TEMP/*.war 
#clear cache
rm -rf $BASE/$Instance_Name/work/*
# Start Tomcat App server
$BIN/tomcat_server.sh start $Instance_Name
sleep 10
chown -R $OWNER:$GROUP $WEBAPPS/*
chown -R $OWNER:$GROUP $LOGS/*
chown -R $OWNER:$GROUP $BASE/$Instance_Name/*
chmod -R 775 $BASE/$Instance_Name/*
chmod -R 775 $LOGS/*

# Send email to deployer
Email=`cat $NOTIFICATION_EMAIL_FILE`
echo "Your deployment  is completed. Check the url to verify your changes." | mail -s "$Instance_Name Autodeploy report" $Email

RTN_CODE=$?
exit $RTN_CODE
