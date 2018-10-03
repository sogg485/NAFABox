################################################
# Under GPL license
#     https://www.gnu.org/licenses/gpl.html
# Authors:	Patrick Dutoit
# 			Laurent Roge
# On June 10 2017
# V0.1
################################################
#!/bin/bash
######
# Recherche du répertoire ConfigTinker
######
dirinstall=$(head -n 1 temp_directory.tmp)
######
# recupere le user
######
moi=$(whoami)
data=$dirinstall
######
# detect language
######
source detect_language.sh | tee -a "$dirinstall/nafabox.log"
######
# Installation du serveur webdav
######
# Extras nginx
sudo apt -y install nginx-extras
# copy of the server file
cat $data/webdav-server.txt | sed -e "s/MOI/${moi}/g" > /tmp/site-webdav
sudo cp /tmp/site-webdav /etc/nginx/sites-available/.
sudo chown $moi:$moi /etc/nginx/sites-available/site-webdav
sudo ln -sf /etc/nginx/sites-available/site-webdav /etc/nginx/sites-enabled/site-webdav
# Restart nginx
sudo service nginx stop
sleep 2
sudo service nginx start




