#!/bin/sh
if [ ! -e "$DB_FILE" ]
then 
  echo "Database $DB_FILE not found!\nPlease check if you mounted the bitwarden_rs volume with '--volumes-from=bitwarden'"!
  exit 1;
fi

# setup dropbox uploader config file
echo "OAUTH_ACCESS_TOKEN=${DROPBOX_ACCESS_TOKEN}" > ~/.dropbox_uploader

# setup environment for cron job
echo "export DB_FILE=${DB_FILE}" > ~/.backup_cmd.env
echo "export BACKUP_FILE=${BACKUP_FILE}" >> ~/.backup_cmd.env
echo "export TIMESTAMP=${TIMESTAMP}" >> ~/.backup_cmd.env
echo "export DELETE_AFTER=${DELETE_AFTER}" >> ~/.backup_cmd.env

BACKUP_CMD=". ~/.backup_cmd.env; /app/backup.sh"


# Just run the backup script
if [ "$1" = "manual" ]; then
  $BACKUP_CMD
  exit 0
fi



# Initialize cron
echo "Initalizing cron..."
echo "$CRON_TIME $BACKUP_CMD >> $LOGFILE 2>&1" | crontab -

pgrep crond > /dev/null 2>&1
if [ $? -ne 0 ]; then
   sudo /usr/sbin/crond -L /app/log/cron.log
fi



echo "$(date "+%F %T") - Container started" > "$LOGFILE"
tail -F "$LOGFILE" /app/log/cron.log
