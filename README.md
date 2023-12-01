# File Backup Script

This is a Bash script for creating backups of specified directories, using configuration files. The script takes in command-line arguments in the form of options and a configuration name, and creates a new backup directory with the specified retention policy (daily, weekly, monthly, yearly) if set.

The script creates a new backup directory and backups each specified directory to a separate tar.bz2 file within the directory. It writes various log messages throughout the process, including the start and end time, the backup path, the backup size, and whether the backup creation was successful. Finally, it copies the log file to the backup directory and prints a message indicating that the backup creation is done.

## Usage

Syntax:

    files-backup [-c CONFIG_DIR][-r RETENTION_POLICY][-m] CONF_NAME
    files-backup -h

* `CONF_NAME` - the name of the configuration file to be used for the backup. 
This file should be located in the directory specified by `-c` option.

### Options

| Short option | Long option    | Description                                                                                                                                  | Default Value       |
|--------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| `-c`         | `--config-dir` | Directory containing configuration files                                                                                                     | `/etc/files-backup` |
| `-r`         | `--retention`  | Retention policy type. Possible values: daily, weekly, monthly, yearly. If set, the value will be used as a suffix in the subdirectory name. | `<empty>`           |
| `-m`         | `--send-mail`  | Send an email notification after the backup is complete. If this flag is set, make sure to set the email address in the configuration file.  |                     |
| `-h`         | `--help`       | Show help                                                                                                                                    |                     |

## Configuration

Configuration files should be placed in the directory specified by the `-c` option or the default directory (`/etc/files-backup`). 
Each configuration file should have a `.cfg` extension and contain the following variables:

* `ROOT` - root directory of the files to be backed up
* `EMAILFROM` - email address from which backup summary should be sent
* `EMAILTO` - email address where backup summary should be sent
* `BACKUP_PREFIX` - prefix to be added to the backup directory name
* `DIR` - directory where the backup should be stored

Additionally, an optional `.exclude` file can be included in the configuration directory to specify files or directories to exclude from the backup.

## Output

The script will create a backup directory with a name in the format `BACKUP_PREFIX_DATEF` where `DATEF` is the date and time the backup was created. 
Within this directory, each file specified in the configuration file will be backed up as a compressed `.tar.bz2` file.

A log file will be created in the temporary directory (`/tmp/backup.log`) and emailed to the address specified in the configuration file.

## Installation

### Add `srnjak` apt source

To add the `srnjak` apt source to your system, follow these steps:

1. Update the package index:
    ```
    sudo apt-get update
    ```

2. Install the required packages:
    ```
    sudo apt-get install -y ca-certificates gnupg2 curl
    ```

3. Add the `srnjak` repository to your system's package sources:
    ```
    echo "deb https://ci.srnjak.com/nexus/repository/apt-release release main" | sudo tee /etc/apt/sources.list.d/srnjak.list
    ```

4. Add the repository's GPG key to your system's trusted keys:
    ```
    curl -sSL https://ci.srnjak.com/nexus/repository/public/gpg/public.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/srnjak.gpg
    ```

### Install `files-backup`

To install the `files-backup` package, follow these steps:

1. Update the package index again:
    ```
    sudo apt-get update
    ```

2. Install the `files-backup` package:
    ```
    sudo apt-get install -y files-backup
    ```

## Dependencies
The script uses the following dependencies:

- `tar`
- `bzip2`
- `mailutils` (optional)
- `backup-scheduler`

Note: The script will work without `mailutils`, but won't be able to send mail after the backup process is done. `tar` and `bzip2` are required for compressing and archiving the backup files.

## Automated Backups Configuration

To automate your backups, store the configuration file at `/etc/files-backup/_schedule.cfg`. 
This file sets the backup frequency and email notification preferences. 
After configuring this file, backups will run automatically as scheduled.

### Configuration File Format

The INI-formatted file designates retention policies (daily, weekly, monthly, or yearly) with backup names and corresponding email notification settings.

### Example Configuration:

```ini
# Backup scheduler configuration

[daily]
user-documents=no_mail
website-html=no_mail

[weekly]
# user-documents=mail
family-photos=mail

[monthly]
user-documents=mail
website-html=mail

[yearly]
user-documents=mail
family-photos=mail
```

### Execution

Once configured, backups will execute automatically at specified intervals. 
Place the configuration file at `/etc/files-backup/_schedule.cfg` and tailor it to your needs for efficient and personalized automated backups.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
