This is a backup script that performs a weekly backup of OpenNMS configuration files and the database, and copies backup files to a remote SMB share.

The RRD historical data files are not backed up -- if these are desired, uncomment the script section below about files in `/var/lib/opennms` (this is where these files are on Debian/Ubuntu systems). 

Ensure `/sbin/mount.cifs` exists; install packages as needed.

## Create the backup script

```	
touch /etc/cron.weekly/opennms-backup
chmod +x /etc/cron.weekly/opennms-backup
vi /etc/cron.weekly/opennms-backup
```