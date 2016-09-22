#!/bin/ksh
  
#Enter correct  tomcat admin logn and password in tomcat-users.xml file
#awk 'NR>1{print buf}{buf = $0}' tomcat-users.xml > temp
#mv temp tomcat-users.xml
#cat tomcat_admin.txt >> tomcat-users.xml
TEMPLATES="/u01/apache_tomcat_group/templates"
Server_Name=`hostname`
echo "Server_Name: $Server_Name"
sed "s/Server_Name/$Server_Name/g" $TEMPLATES/jsvc.properties > $TEMPLATES/jsvc.properties_test
