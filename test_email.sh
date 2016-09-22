#!/bin/sh
# Send email to deployer
NOTIFICATION_EMAIL_FILE="/u01/apache_tomcat_group/deploy/TEST/notification/email.txt"
Instance_Name="TEST DEPLOY APP"
Email=`cat $NOTIFICATION_EMAIL_FILE`
echo "Your deployment  is completed. Check the url to verify your changes." | mail -s "$Instance_Name Autodeploy report" $Email

