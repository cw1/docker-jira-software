#!/bin/bash
set -o errexit

. /usr/local/share/atlassian/common.bash

own-volume
rm -f /opt/atlassian-home/.jira-home.lock

if [ "$CONTEXT_PATH" == "ROOT" -o -z "$CONTEXT_PATH" ]; then
  CONTEXT_PATH=
else
    CONTEXT_PATH="/$CONTEXT_PATH"
fi
    
if [ -n "$DATABASE_URL" ]; then
  extract_database_url "$DATABASE_URL" DB /opt/jira/lib
  DB_JDBC_URL="$(xmlstarlet esc "$DB_JDBC_URL")"
  SCHEMA=''
  if [ "$DB_TYPE" != "mysql" ]; then
      SCHEMA='<schema-name>public</schema-name>'
  fi
  cat <<- EOF > /opt/atlassian-home/dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<jira-database-config>
<name>defaultDS</name>
<delegator-name>default</delegator-name>
<database-type>$DB_TYPE</database-type>
$SCHEMA
<jdbc-datasource>
<url>$DB_JDBC_URL</url>
<driver-class>$DB_JDBC_DRIVER</driver-class>
<username>$DB_USER</username>
<password>$DB_PASSWORD</password>
<pool-min-size>20</pool-min-size>
<pool-max-size>20</pool-max-size>
<pool-max-wait>30000</pool-max-wait>
<pool-max-idle>20</pool-max-idle>
<pool-remove-abandoned>true</pool-remove-abandoned>
<pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
</jdbc-datasource>
</jira-database-config>
EOF
fi

/opt/jira/bin/start-jira.sh -fg
   
