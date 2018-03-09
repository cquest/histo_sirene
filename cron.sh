# récupération des nouveaux fichiers
for f in $(curl 'http://files.data.gouv.fr/sirene/' -s | grep 'sirene_[0-9]*_E_Q.zip' -o); do wget http://files.data.gouv.fr/sirene/$f -nc -q ; done

# extraction des changements de SIRET
for f in *.zip
do
  FILE=$(echo $f | sed 's/.zip//')
  if [ ! -f $FILE-histo.csv ]
  then
    bash histo_sirene.sh $f
  fi
done

# fichier cumulé sur l'année
csvstack sirene_2018*.csv > histo_sirene_2018.csv

# publication...
cp *.csv /var/www/html/data/histo_sirene
