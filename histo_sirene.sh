#!/bin/bash

# extraction des changements de SIRET dans les fichiers de maj quotidien SIRENE

# unzip = décompression du zip
# iconv = conversion de l'encodage
# csvcut = extraction des colonnes qui nous intéressent + conformation CSV
# egrep = extraction de slignes qui nous intéressent
# csvsql = rapprochement pour obtenir le lien ancien -> nouveau SIRET

# dépendances: csvkit, unzip (sudo apt install csvkit unzip)

unzip -p $1 | iconv -f cp1252 -t utf8 |
csvcut -c SIREN,DATEMAJ,NIC,SIRETPS,NICSIEGE,VMAJ,EVE -d ';' -v| \
egrep '(^SIREN|,(CTE|CTS|MTDE|MTAE|MTDS|MTAS|STE|STS|SU)$)' | \
csvsql --query "SELECT siret_old, siret_new, datemaj FROM (SELECT o.siren||substr('0000' || o.nic, -5, 5) AS siret_old, n.siren||substr('0000' || n.nic, -5, 5) AS siret_new, o.datemaj FROM stdin o JOIN stdin n ON (o.siren=n.siren AND o.datemaj=n.datemaj AND o.nic<n.nic) UNION SELECT siretps as siret_old, siren||substr('0000' || nic, -5, 5) as siret_new, datemaj FROM stdin WHERE siretps <> '' AND cast(siren AS text) <> substr(siretps, 0, 10)) AS histo GROUP BY siret_old, siret_new, datemaj ORDER BY datemaj;" > ${1/.zip}-histo.csv
