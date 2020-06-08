#!/bin/bash
 
# define backup destination
LOCALDIR=/mnt/backup
 
# ensure the backup directory exists
if ! [ -e $LOCALDIR ] ; then
    mkdir -p $LOCALDIR
fi
 
# Creating timestamp
dsig=`date +%Y%m%d%H%M%S`
 
# Back up Postgres DB
pg_dump -U opennms -Fc -f $LOCALDIR/$dsig-database.pgsql.gz opennms
 
# Back up rrd archives
tar cvfz $LOCALDIR/$dsig-rrd.tar.gz /opt/opennms/share/rrd/
 
# Back up config files
tar cvfz $LOCALDIR/$dsig-config.tar.gz /opt/opennms/etc
 
# Delete all backups older than 30 days
find $LOCALDIR -name '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*.gz' -atime +30 -exec echo Deleting: {} \; -delete