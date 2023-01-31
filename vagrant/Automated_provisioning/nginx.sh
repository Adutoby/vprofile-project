# adding repository and installing nginx		
apt update
apt install nginx -y
cat <<EOT > vproapp
upstream vproapp {

 server app01:8080;

}

server {

  listen 80;

location / {

  proxy_pass http://vproapp;

}

}

EOT

# moving vproapp file into the sites-available
mv vproapp /etc/nginx/sites-available/vproapp
#removing the default nginx in the sites-enabled
rm -rf /etc/nginx/sites-enabled/default
# link the vproapp to the sites-enabled
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

#starting nginx service and firewall
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
