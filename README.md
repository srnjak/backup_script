# File Backup Script

This is a bash script for creating backups of files specified in a configuration file.

## Usage

Syntax:

    ./backup.sh [-c CONFIG_DIR][-r RETENTION_POLICY] CONF_NAME
    ./backup.sh -h

* `CONF_NAME` - the name of the configuration file to be used for the backup. 
This file should be located in the directory specified by `-c` option.

### Options

| Option               | Description                                                                                                                                  | Default Value       |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| `-c`, `--config-dir` | Directory containing configuration files                                                                                                     | `/etc/files-backup` |
| `-r`, `--retention`  | Retention policy type. Possible values: daily, weekly, monthly, yearly. If set, the value will be used as a suffix in the subdirectory name. | `<empty>`           |
| `-h`, `--help`       | Show help                                                                                                                                    | N/A                 |

## Configuration

Configuration files should be placed in the directory specified by the `-c` option or the default directory (`/etc/files-backup`). 
Each configuration file should have a `.cfg` extension and contain the following variables:

* `ROOT` - root directory of the files to be backed up
* `EMAILTO` - email address where backup summary should be sent
* `BACKUP_PREFIX` - prefix to be added to the backup directory name
* `DIR` - directory where the backup should be stored

Additionally, an optional `.exclude` file can be included in the configuration directory to specify files or directories to exclude from the backup.

## Output

The script will create a backup directory with a name in the format `BACKUP_PREFIX_DATEF` where `DATEF` is the date and time the backup was created. 
Within this directory, each file specified in the configuration file will be backed up as a compressed `.tar.bz2` file.

A log file will be created in the temporary directory (`/tmp/backup.log`) and emailed to the address specified in the configuration file.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
