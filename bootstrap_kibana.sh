#!/usr/bin/env bash
su

# Bonus, install Kibana.
echo "Installing Kibana"
cd /opt
wget --quiet https://download.elastic.co/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz
tar xf kibana-4.0.2-linux-x64.tar.gz
rm kibana-4.0.2-linux-x64.tar.gz
mv kibana-4.0.2-linux-x64 kibana
cd /etc/init.d
wget --quiet --no-check-certificate https://gist.githubusercontent.com/philwinder/a86b5528608fd0295c60/raw/kibana4 --output-document=kibana4
chmod 755 kibana4

echo "Starting Kibana4"
# Start nginx
chkconfig --add kibana4
service kibana4 start

echo "Updating nginx config to allow kibana at the address http://localhost:8080/kibana4"
service nginx stop
cd /usr/local/openresty/nginx/conf
rm -f nginx.conf
wget --quiet --no-check-certificate https://gist.githubusercontent.com/philwinder/5ec7628c6687794029b3/raw/nginx_authorize_by_lua_kibana.conf --output-document=nginx.conf
service nginx start
