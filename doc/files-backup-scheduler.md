# Files Backup Scheduler

This is a bash script for running backups periodically according to the specified retention policy (daily, weekly, monthly, or yearly) and a list of backup names provided in a file. The script is intended to be run from a cronjob.

## Usage

```
files-backup-scheduler [-r|--retention POLICY] [-c|--config FILE] [-m|--send-mail]
```

### Options

- `-r, --retention <policy>`: The retention policy of the backup (daily, weekly, monthly, or yearly)
- `-c, --config <file>`: Configuration file
- `-m, --send-mail`: Send email notification after each backup

### Examples

Run backups every day at 2am:

```
0 2 * * * /path/to/files-backup-scheduler -r daily -c /path/to/config
```

## Configuration file

The script uses a configuration file to determine the backup frequency and email notification settings for each backup. 
The configuration file should be in the INI format, where each section corresponds to a retention policy and contains a list of backup names with their corresponding email notification settings.

### Example configuration file:

```
# The backup scheduler configuration

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

In this example, there are four retention policies: `daily`, `weekly`, `monthly`, and `yearly`. The script only supports these four retention policies.

Each policy has a list of backups, and their corresponding email notification settings. 
The email notification settings can take two values: `no_mail` and `mail`. 
If a backup's email notification setting is set to `mail`, the script will send an email notification after the backup is complete. 
If the setting is set to `no_mail`, no email notification will be sent.

In this example, you can see that the # character is used at the beginning of a line to indicate a comment.
Any text following the # character on the same line is ignored by the script.
