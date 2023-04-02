#!/bin/bash

# Initialize variables with default values
CONFIG_DIR=/etc/files-backup

printHelp() {
  cat <<EOF

  Usage: $0 [OPTIONS] <CONF_NAME>

  Create a backup of the specified directory using the specified configuration file.

  OPTIONS:
    -c, --config-dir DIR     Set the directory containing the configuration files (default: /etc/files-backup)
    -r, --retention POLICY   Retention policy type. Possible values: daily, weekly, monthly, yearly. If set, the value will be used as a suffix in the subdirectory name.
    -h, --help                  Print this help message and exit.

  CONF_NAME:
    The name of the configuration file to use. This file should be located in the directory specified by the -c option.

  EXAMPLES:
    $0 my_config    Create a backup using the configuration file my_config.cfg located in /etc/files-backup.
    $0 -c /path/to/configs my_config    Create a backup using the configuration file my_config.cfg located in /path/to/configs.
    $0 -r weekly my_config       Create a backup using the configuration file my_config.cfg located in /etc/files-backup, and append 'weekly' to the backup directory name.

EOF
}

function checkVariable {
  if [ -z "${!1}" ]; then
      echo "Variable \"$1\" not set."
      exit 1
  fi
}

LOG_FILE="/tmp/backup.log"
rm -f $LOG_FILE

function write {
  echo -e "$1"
  echo -e "$1" >> $LOG_FILE
}

function log {
  cas=$(date +"%H:%M:%S")
  write "[$cas] $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--config-dir)
      CONFIG_DIR="$2"
      shift 2
      ;;
    -r|--retention)
        RETENTION_POLICY="$2"
        shift
        ;;
    -h|--help)
      printHelp
      exit 0
      ;;
    -*)
      printHelp
      exit 0
      ;;
    *)
      CONF_NAME="$1"
      shift
      ;;
  esac
done

if [ -z "$CONF_NAME" ]; then
    echo "Configuration name missing!"
    exit 1
fi

# Validate retention policy option
if [[ -v RETENTION_POLICY ]] && \
   ! [[ $RETENTION_POLICY =~ ^(daily|weekly|monthly|yearly)$ ]]; then
    echo "Error: Invalid retention policy option. Valid options are 'daily', 'weekly', 'monthly', or 'yearly'." >&2
    exit 1
fi

# The script path
SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/"

# Configurations
CONFIG="$CONFIG_DIR/$CONF_NAME.cfg"
EXCLUDE="$CONFIG_DIR/$CONF_NAME.exclude"

# Set variables from config file
# shellcheck disable=SC2086
if [ -f $FILE ]; then
  # shellcheck source=config/system.cfg
  . "$CONFIG"
fi

checkVariable ROOT
checkVariable EMAILTO
checkVariable BACKUP_PREFIX
checkVariable DIR

# DATE format
DATE=$(date +'%F %X')

# DATE format in filename
DATE_F=$(date +'%Y-%m-%d_%H%M%S')

# Path to a new backup
if [ -n "$RETENTION_POLICY" ]; then
    BACKUP_SUBDIR="${BACKUP_PREFIX}_${DATE_F}_${RETENTION_POLICY}"
else
    BACKUP_SUBDIR="${BACKUP_PREFIX}_${DATE_F}"
fi
BACKUP_DIR="$DIR/$BACKUP_SUBDIR"

touch $LOG_FILE

clear

write "\n***************************************"
write "BACKUP CREATION"
write "***************************************"
write "DATE         : $DATE"
write "Backup path  : $ROOT"
write "Prefix       : $BACKUP_PREFIX"
write "Script path  : $SCRIPT_PATH"
write "Backup dir   : $BACKUP_DIR"
write " "
write "E-mail (to)  : $EMAILTO"
write "***************************************\n"

# Creating new directory for the backup
log "Creating path $BACKUP_DIR ... \c"
mkdir "$BACKUP_DIR"
write "OK"

# Backup creation
write "\nCREATING BACKUPS\n";

write "Backup creation start ...\n"
for i in "$ROOT"/*; do
  CURRENT_DIR=$(basename "$i")

  log "Packing: $CURRENT_DIR ... \c"

  if [ -f "$EXCLUDE" ]; then
    tar -cjf "$BACKUP_DIR/$CURRENT_DIR.tar.bz2" -X "$EXCLUDE" "$i" > /dev/null 2>&1
  else
    tar -cjf "$BACKUP_DIR/$CURRENT_DIR.tar.bz2" "$i" > /dev/null 2>&1
  fi
  write "OK ($(du -hs "$BACKUP_DIR/$CURRENT_DIR.tar.bz2" | awk '{print $1}'))"

done

write "\nBackup creation done.\n\n"


log "BACKUP CREATION DONE.\n\n"

# End of backup creation
#cd /

# size data
write "Backup size: \c"
SIZE=$(du -hs "$BACKUP_DIR" | awk '{print $1}')
write "$SIZE"

cp "$LOG_FILE" "$BACKUP_DIR"
# finnish
write "\n*********************************"
write "BACKUP CREATION DONE."
write "*********************************"

# sending mail
HOST=$(hostname)
SUMMARY="Backup $CONF_NAME ($HOST); size: $SIZE"

sed -i "1s/^/Subject: $SUMMARY\n/" $LOG_FILE
sendmail "$EMAILTO" < $LOG_FILE

rm $LOG_FILE
