#!/bin/bash
APP_DIR=/home/<USER>/${APP_NAME}
TARGET=${APP_DIR}/${APP_NAME}
PID_FILE=${APP_DIR}/RUNNING_PID
DAEMON=./bin/${APP_NAME}

# [Creating ticket Kerberos] ##
echo "Starting Ticket Creation"
/usr/bin/kinit <USER>@PIPOCA.DOMAIN -k -t ${KEYTAB_HOME}/pirulito.keytab
if [ $? == 0 ]; then
  /usr/bin/klist
  echo "Creating 'job' to refresh the ticket every 12 hours"
  while true; do /usr/bin/kinit -kt /etc/security/keytabs/pirulito.keytab <USER>@PIPOCA.DOMAIN -r7d; sleep 43200; done &
else
  echo "Error generating a ticket in Kerberos. Validate the settings."
  exit 1
fi

# [Starting application] ##
if [ -e $PID_FILE ]; then
  echo "Application is running. Stopping $APP_NAME ..."
  kill -9 `cat $PID_FILE`
  rm -f $PID_FILE
else
  rm -f $PID_FILE
  echo "$APP_NAME is not running"
fi

  echo "Starting $APP_NAME..."
$DAEMON -Dplay.http.secret.key=c4br-dolphin -Dhttp.port=$APP_PORT
