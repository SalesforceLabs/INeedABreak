bold=$(tput bold)
normal=$(tput sgr0)

echo ${bold}Create Scratch Org$1${normal}
echo sfdx force:org:create -f config/project-scratch-def.json --setalias $1 --setdefaultusername --durationdays $2 --targetdevhubusername devhubldo
sfdx force:org:create -f config/project-scratch-def.json --setalias $1 --setdefaultusername --durationdays $2 --targetdevhubusername devhubldo
sleep 5
echo -e

echo ${bold}Install Package${normal}
echo sfdx force:package:install --package "04t4x000000AIkdAAG" --wait 10 --publishwait 10
sfdx force:package:install --package "04t4x000000AIkdAAG" --wait 10 --publishwait 10
echo -e



echo ${bold}Run Test Class${normal}
echo sfdx force:apex:test:run -n "OutOfTheOfficeBatchableOOORTEST" -c -r human -w 20
sfdx force:apex:test:run -n "OutOfTheOfficeBatchableOOORTEST" -c -r human -w 20
echo -e

echo ${bold}Open Scratch Org: $1${normal}
echo sfdx force:org:open
sfdx force:org:open
