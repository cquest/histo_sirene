# extraction des changements de SIRET dans les fichiers de maj quotidien SIRENE

# unzip = décompression du zip
# csvcut = extraction des colonnes qui nous intéressent + conformation CSV
# egrep = extraction de slignes qui nous intéressent
# csvsql = rapprochement pour obtenir le lien ancien -> nouveau SIRET

# dépendances: csvkit, unzip (sudo apt install csvkit unzip)

FILE=$(echo $1 | sed 's/.zip//')
unzip $1
csvcut -c SIREN,DATEMAJ,NIC,SIRETPS,NICSIEGE,VMAJ,EVE -d ';' -e iso8859-1 sirc* | \
egrep '(^SIREN|,(CTE|CTS|MTDE|MTAE|MTDS|MTAS|STE|STS|SU)$)' | \
csvsql --query 'select o.siren||o.nic as SIRET_OLD, n.siren||n.nic as SIRET_NEW, o.datemaj from stdin o join stdin n on (o.siren=n.siren and o.datemaj=n.datemaj and o.nic<n.nic);' > $FILE-histo.csv
rm sirc*
