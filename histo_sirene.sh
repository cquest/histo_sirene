#!/bin/bash

# extraction des changements de SIRET dans les fichiers de maj quotidien SIRENE

# unzip = décompression du zip
# iconv = conversion de l'encodage
# csvcut = extraction des colonnes qui nous intéressent + conformation CSV
# egrep = extraction de slignes qui nous intéressent
# csvsql = rapprochement pour obtenir le lien ancien -> nouveau SIRET

# dépendances: csvkit, unzip (sudo apt install csvkit unzip)

unzip -p $1|iconv -f cp1252 -t $(locale charmap) |
csvcut -c SIREN,DATEMAJ,NIC,SIRETPS,NICSIEGE,VMAJ,EVE -d ';' -v|
egrep '(^SIREN|,(CTE|CTS|MTDE|MTAE|MTDS|MTAS|STE|STS|SU)$)' |
csvsql --query "select o.siren||substr('0000' || o.nic, -5, 5) as SIRET_OLD, \
                       n.siren||substr('0000' || n.nic, -5, 5) as SIRET_NEW, \
                       o.datemaj \
                    from stdin o \
                    join stdin n on (o.siren=n.siren and o.datemaj=n.datemaj and o.nic<n.nic) \
                    left join stdin f on f.siren=n.siren and f.datemaj=n.datemaj and f.nic < n.nic and f.nic > o.nic \
                    where f.siren is null \
                  union \
                select siretps as siret_old,\
                       siren||substr('0000' || nic, -5, 5) as siret_new, \
                       datemaj \
                    from stdin \
                    where siretps <> '' and cast(siren as text) <> substr(siretps, 0, 10) \
                    order by datemaj, siret_new, siret_old;" > ${1/.zip}-histo.csv

