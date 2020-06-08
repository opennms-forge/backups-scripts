This is a backup script that performs a daily backup of OpenNMS configuration files, the database and rrd archives and keeps the last 30 backups.
Ensure your backup folder /mnt/backup is mounted.

## Create the backup script

```	
touch /etc/cron.daily/opennms-backup
chmod +x /etc/cron.daily/opennms-backup
vi /etc/cron.daily/opennms-backup
```