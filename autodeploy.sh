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
#Run script as Tomcat user
#sudo su $OWNER

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
         autodeploy="yes"
         # Stop Tomcat App server
         sudo su - $OWNER $BIN/tomcat_server.sh stop $Instance_Name
         sleep  20
         autodeploy="yes"
         break 
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
              sudo rm -rf $WEBAPPS/$expanded_folder
           fi
         fi 
done
# Copy New warfiles from temp folder to webapps folder
mv $TEMP/*.war $WEBAPPS/
sudo chmod -R ug+rwx $WEBAPPS/*.war
sudo chown -R $OWNER:$GROUP $WEBAPPS/*
rm -f $TEMP/*.war 
#clear cache
sudo rm -rf $BASE/$Instance_Name/work/*
# Start Tomcat App server
sudo su - $OWNER $BIN/tomcat_server.sh start $Instance_Name
sleep 20
sudo chown -R $OWNER:$GROUP $WEBAPPS/*
sudo chown -R $OWNER:$GROUP $LOGS/*
sudo chown -R $OWNER:$GROUP $BASE/$Instance_Name/*
sudo chmod -R 775 $BASE/$Instance_Name/*
sudo chmod -R 775 $LOGS/*
