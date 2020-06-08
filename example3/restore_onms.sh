#!/bin/bash
 
LOGFILE="Logs/InstallDB.log"
BackupFile="/opennms/backup/OpenNMS.pgsqlbin.*.gz/"
# restore last backup db
clear
echo -ne "\n ------ RESTORE LAST BACKUP OF DB ------\n"
echo -ne    "---------------------------------------\n"
echo -ne "pg_restore -U opennms -d opennms -c $BackupFile\n"
echo -ne "-------------------------------------------------------------------------\n"
echo -ne " THIS INSTALLS A CLEAN DB from the backup  - you must be SUDO and then run the opennms install -dis after to update teh db\n\n\n"
 
pg_restore -U opennms -d opennms -c /opennms/backup/OpenNMS.pgsqlbin.*.gz/ | tee $LOGFILE
 
/opennms/bin/install -dis