bold=$(tput bold)
normal=$(tput sgr0)

echo ${bold}Create Scratch Org$1${normal}
echo sfdx force:org:create -f config/project-scratch-def.json --setalias $1 --setdefaultusername --durationdays $2 --targetdevhubusername devhubldo
sfdx force:org:create -f config/project-scratch-def.json --setalias $1 --setdefaultusername --durationdays $2 --targetdevhubusername devhubldo
sleep 5
echo -e

echo ${bold}Push Package${normal}
echo sfdx force:source:push --forceoverwrite --loglevel fatal --wait 30
sfdx force:source:push --forceoverwrite --loglevel fatal --wait 30
echo -e


echo ${bold}Create Backup User${normal}
echo sfdx force:user:create -a oooBackupUser -f config/ooor_backup_user.json
sfdx force:user:create -a oooBackupUser -f config/ooor_backup_user.json
echo -e

echo ${bold}Apply OOO Admin Perm Set to Scratch Org User${normal}
echo sfdx force:user:permset:assign -n OutOfTheOfficeAdmin_OOOR
sfdx force:user:permset:assign -n OutOfTheOfficeAdmin_OOOR
echo -e

echo ${bold}Apply Create OOO On Behalf of Other User Perm Set to Scratch Org User${normal}
echo sfdx force:user:permset:assign -n OutOfTheOfficeCreateOOOOnBehalfOfOthers_OOOR
sfdx force:user:permset:assign -n OutOfTheOfficeCreateOOOOnBehalfOfOthers_OOOR
echo -e

echo ${bold}Run Test Class${normal}
echo sfdx force:apex:test:run -n "OutOfTheOfficeBatchableOOORTEST" -c -r human -w 20
sfdx force:apex:test:run -n "OutOfTheOfficeBatchableOOORTEST" -c -r human -w 20
echo -e

echo ${bold}Open Scratch Org: $1${normal}
echo sfdx force:org:open
sfdx force:org:open
