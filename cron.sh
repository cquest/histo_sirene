# récupération des nouveaux fichiers
for f in $(curl 'http://files.data.gouv.fr/sirene/' -s | grep 'sirene_[0-9]*_E_Q.zip' -o); do wget http://files.data.gouv.fr/sirene/$f -nc; done

# extraction des changements de SIRET
for f in *.zip
do
  FILE=$(echo $f | sed 's/.zip//')
  if [ ! -f $FILE-histo.csv ]
  then
    sh histo_sirene.sh $f
  fi
done

# publication...
rsync *.csv root@sc1.cquest.org:/var/www/html/histo_sirene -av
