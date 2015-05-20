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
wget --quiet --no-check-certificate https://github.com/philwinder/elasticsearch-secure-http/blob/master/init/kibana4 --output-document=kibana4
chmod 755 kibana4

echo "Starting Kibana4"
# Start nginx
chkconfig --add kibana4
service kibana4 start

echo "Updating nginx config to allow kibana at the address http://localhost:8080/kibana4"
service nginx stop
cd /usr/local/openresty/nginx/conf
rm -f nginx.conf
wget --quiet --no-check-certificate https://raw.githubusercontent.com/philwinder/elasticsearch-secure-http/master/conf/nginx_authorize_by_lua_kibana.conf --output-document=nginx.conf
service nginx start
