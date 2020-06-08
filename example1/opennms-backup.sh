#!/bin/bash
 
# define backup destination
LOCALDIR=/mnt/backup
VERSIONINFOFILE=$LOCALDIR/opennms_backup_versions.txt
 
# backup subroutine
backup_item()
{
    ARCHIVE=$1
    if [ ${ARCHIVE:0:1} == '/' ]; then
       ARCHIVE=${ARCHIVE:1}  # remove leading slash
    fi
    ARCHIVE=${ARCHIVE//\//_}  # convert remaining slashes to underscores
 
    tar -zcpf $LOCALDIR/$ARCHIVE.tar.gz $1 2>&1 | grep -v 'Removing leading'
}
 
# ensure the backup directory exists
if ! [ -e $LOCALDIR ] ; then
    mkdir -p $LOCALDIR
fi
 
# mount the backup target directory using CIFS
mount -t cifs -o username=username,password=secretpassword \\\\smbservername\\OpenNMSBackup /mnt/backup
 
# back up the OpenNMS PostgreSQL database
su - postgres -c "pg_dump --format=c opennms" | gzip > $LOCALDIR/opennms.postgresql.backup.gz
 
# save OpenNMS and related program version numbers for future reference
dpkg -l | grep opennms > $VERSIONINFOFILE
dpkg -l | grep postgresql >> $VERSIONINFOFILE
dpkg -l | grep iplike >> $VERSIONINFOFILE
dpkg -l | grep jre >> $VERSIONINFOFILE
java -version 2>> $VERSIONINFOFILE
 
# back up the OpenNMS etc directory and all subfolders to store the OpenNMS configuration
backup_item /etc/opennms
 
# back up the OpenNMS var/lib directory and all subfolders to store gathered statistics
#   warning: this can be large (hundreds of MB or several GB)
##backup_item /var/lib/opennms
 
# unmount the backup target
umount /mnt/backup