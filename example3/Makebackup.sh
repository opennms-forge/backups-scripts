#!/bin/bash
 
## BACKUP OPENNMS SCRIPT
## by Paul Cole - omdreams@gmail.com
## intention :  to backup current opennms configuration and data to a directory  and log it
##              expectations - run as sudo - provide  ability to be run as cronjob
##              Best practice - copy to separate dirve or NFS mounted share
##  accepts commandline options  for  $1 = mode of backup   - if not FULL then will accept $2 $3 $4 for additional options
##              FULL or F  = FULL BACKUP with RRD and SQL and ALL ETC
#               ETC or E = ETC directory only
#               RRD or R = RRD data ( historical SNMP statistics data )
#               SQL or S = SQL only  data
#               PARTIAL or P = SQL and ETC only
 
## Declarations
DATE=$(date +"%Y%m%d.%H%M")
LOGFILE="backuplog.$DATE.log"
BKPPATH="/data/opennms/backups"
BKPOLDPATH="/data/opennms/oldbackups"
BKPLOGPATH="/data/opennms/backups"
BKPMODE="FULL"
 
## begin
#check if right privs
if [ "$(whoami)" != "root" ]
   then
        echo "Sorry, you are not running with Sufficient Privlidges - try with sudo ."
        exit 1
fi
## check CMNDLINE ARGS
if [ ! -z "$1" ]
   then
        echo "CMD LINE ARGS NOT YET ACCEPTED"
        exit 1
fi
clear
echo "-----------------------------------------------------------"
echo " OpenNMS Backup Script by Paul Cole : omdreams@gmail.com "
echo "-----------------------------------------------------------"
echo "."
#sanity checks
if [ ! -e $BKPPATH ]
   then
        mkdir $BKPPATH
        echo "Backupdir $BKPPATH DOES NOT EXIST - created it"
fi
 
if [ ! -e $BKPOLDPATH ]
   then
        mkdir $BKPOLDPATH
        echo "Backupdir $BKPOLDPATH DOES NOT EXIST - created it"
fi
 
if [ ! -e $BKPLOGPATH ]
   then
        mkdir $BKPLOGPATH
        echo "Backupdir $BKPLOGPATH DOES NOT EXIST - created it"
fi
 
#start logging
LOG="$BKPLOGPATH/$LOGFILE"
echo "Logging to $LOG"
echo "--------------------------------------" | tee $LOG
echo " Moving old backups and initializing "
echo "-------- FileStamp $DATE ----------" | tee -a $LOG
# mv /usr/share/opennms/backup/* /data/opennms/oldbackups
mv $BKPPATH/* $BKPOLDPATH | tee -a $LOG
 
# Backup the postgres DB opennms only
# echo STOPPING OPENNMS
echo "."
opennms stop | tee -a $LOG
opennms -v status
echo "."
echo "-----------------------------------------------------------" | tee -a $LOG
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): performing vacuum on postgresdb " | tee -a $LOG
        psql -U opennms -c "VACUUM"
 
## SQL dump - BINARY
#if [ "$BKPMODE" == "FULL" ]; then
        FILE="$BKPPATH/OpenNMS.pgsqlbin.$DATE.gz"
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): Backing up Postgres DB as binary dump" | tee -a $LOG
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): pg_dump destination file: $FILE" | tee -a $LOG
        pg_dump -U opennms -Fc -f $FILE >> $LOG
#fi
 
echo "-----------------------------------------------------------" | tee -a $LOG
 
## ETC directory
#if [ "$BKPMODE" == "FULL" ]; then
        FILE=$BKPPATH/OpenNMS.etcbkp.$DATE.tar.gz
        SIZE=$( du -chsS /etc/opennms | grep total )
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): Backing up OpenNMS ETC config directory"
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): Destination file: $FILE" | tee -a $LOG
        echo "          Patience we are compressing $SIZE"  | tee -a $LOG
        tar -acvf $FILE /etc/opennms/ >> $LOG
#fi
 
echo "-----------------------------------------------------------" | tee -a $LOG
 
## RRD directory
#if [ "$BKPMODE" == "FULL" ]; then
        FILE=$BKPPATH/OpenNMS.RRD.$DATE.tar.gz
        SIZE=$( du -chsS  /data/opennms/varlib | grep total )
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): Backing up OpenNMS Round Robin Historical SNMP statistical data" | tee -a $LOG
        echo " $BKPMODE $(date +"%Y%m%d.%H%M"): Destination file: $FILE" | tee -a $LOG
        echo "          Patience we are compressing $SIZE" | tee -a $LOG
        tar -acvf $FILE  /data/opennms/varlib >> $LOG
#fi
 
echo "-----------------------------------------------------------" | tee -a $LOG
 
## REMAINDER OF FILES
FILE=$BKPPATH/OpenNMS.code.$DATE.tar.gz
SIZE=$( du -chsS  /usr/share/opennms | grep total )
echo " $BKPMODE $(date +"%Y%m%d.%H%M"): Backing up remainder of opennms directory Excluding ./etc , ./share ./logs and backups " | tee -a $LOG
echo " $BKPMODE $(date +"%Y%m%d.%H%M"): OpenNMS has consumed $SIZE drive space all inclusive" | tee -a $LOG
tar -acvf $FILE --exclude="$BKPPATH" --exclude="$BKPOLDPATH" --exclude="/usr/share/opennms/share" --exclude="/user/share/opennms/logs"  >> $LOG
 
echo "-----------------------------------------------------------" | tee -a $LOG
 
SIZE=$( du -chsS $BKPPATH | grep total)
echo " $BKPMODE $(date +"%Y%m%d.%H%M"): THIS OpenNMS backup consumed $SIZE drive space all inclusive" | tee -a $LOG
SIZE=$( du -chsS $BKPOLDPATH | grep total)
echo " $BKPMODE $(date +"%Y%m%d.%H%M"): historical OpenNMS backups consume $SIZE drive space all inclusive" | tee -a $LOG
 
echo "--------------------------------------" | tee -a $LOG
echo "-------- COMPLETED  $(date +"%Y%m%d.%H%M") ----------" | tee -a $LOG
echo "--------------------------------------" | tee -a $LOG
opennms start | tee -a $LOG
 
opennms -v status | tee -a $LOG
echo "."
echo " These Backups are stored in  $BKPPATH   and older backups in  $BKPOLDPATH "
echo " To view detailed log type: less $LOG "
echo "."
 
ls -rtalh $BKPPATH