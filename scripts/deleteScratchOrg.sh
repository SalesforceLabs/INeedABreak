bold=$(tput bold)
normal=$(tput sgr0)

echo ${bold}Delete Scratch Org: $1${normal}
echo sfdx force:org:delete --targetusername $1 --targetdevhubusername devhubldo --noprompt
sfdx force:org:delete --targetusername $1 --targetdevhubusername devhubldo --noprompt
