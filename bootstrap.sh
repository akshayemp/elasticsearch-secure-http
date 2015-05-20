#!/usr/bin/env bash

# Install java
su
mkdir ~/Downloads
cd ~/Downloads
echo "Installing java"
if [ ! -f ./java.rpm ]; then
   echo "Downloading java"
   wget --quiet "http://javadl.sun.com/webapps/download/AutoDL?BundleId=106239" --output-document=java.rpm
fi
ln -s /usr/sbin/update-alternatives /usr/sbin/alternatives
rpm -ih --nodeps java.rpm
export JAVA_HOME=/usr/java/jre1.8.0_45/bin

# Install Elasticsearch
echo "Installing elasticsearch"
if [ ! -f ./elastic.tar.gz ]; then
   echo "Downloading elasticsearch"
   wget --quiet "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.2.tar.gz"
fi
tar -xf elasticsearch-1.5.2.tar.gz
mkdir /usr/share/elasticsearch
mv elasticsearch-1.5.2/* /usr/share/elasticsearch
chown vagrant /usr/share/elasticsearch
wget --quiet --no-check-certificate https://raw.githubusercontent.com/philwinder/elasticsearch-secure-http/master/init/elasticsearch 
mv elasticsearch /etc/init.d
chmod +x /etc/init.d/elasticsearch
chkconfig --add elasticsearch
service elasticsearch start

sleep 20


# Post some dummy data to elasticsearch
echo "Inserting test data to elasticsearch"
curl -XDELETE localhost:9200/*

curl -XPOST localhost:9200/_bulk -d '
{ "create" : { "_index" : "log-1234", "_type" : "document", "_id" : "fd9fdas89" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "log-1234", "_type" : "document", "_id" : "fd09fdsa" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "log-5678", "_type" : "document", "_id" : "890fdshj" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "log-9012", "_type" : "document", "_id" : "98fdsah" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "monitor-1234", "_type" : "document", "_id" : "fd9fdajio9s89" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "monitor-1234", "_type" : "document", "_id" : "fd09fdg3sa" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "monitor-1234", "_type" : "document", "_id" : "890fdgf43shj" } }
{ "field1" : "testData" }
{ "create" : { "_index" : "monitor-5678", "_type" : "document", "_id" : "98fg432dsah" } }
{ "field1" : "testData" }'

# Install nginx and lua dependencies
zypper --quiet --no-gpg-checks --non-interactive install readline-devel pcre-devel libopenssl-devel

echo "Installing luaJIT"
wget --quiet http://luajit.org/download/LuaJIT-2.0.4.tar.gz
tar -xf LuaJIT-2.0.4.tar.gz
cd LuaJIT-2.0.4
make
make install
cd ..

echo "Installing nginx with lua support"
wget http://openresty.org/download/ngx_openresty-1.4.3.9.tar.gz
tar -xf ngx_openresty-1.4.3.9.tar.gz
cd ngx_openresty-1.4.3.9
./configure --with-luajit
make
make install
cd ..

# Make some folders to hold the user/pass information
mkdir -p /usr/local/openresty/nginx/conf
mkdir -p /usr/local/openresty/nginx/auth

# Download confs
echo "Downloading nginx and lua conf to /usr/local/openresty/nginx/conf"
cd /usr/local/openresty/nginx/conf
wget --quiet --no-check-certificate https://raw.githubusercontent.com/philwinder/elasticsearch-secure-http/master/conf/nginx_authorize_by_lua.conf --output-document=nginx.conf
wget --quiet --no-check-certificate https://raw.githubusercontent.com/philwinder/elasticsearch-secure-http/master/conf/authorize.lua

# Download example htpasswd file
echo "Downloading example htpasswd file to /etc/nginx/auth"
cd /usr/local/openresty/nginx/auth
wget --quiet --no-check-certificate https://raw.githubusercontent.com/philwinder/elasticsearch-secure-http/master/conf/htpasswd

echo "Setting up init.d script"
cd /etc/init.d
wget --quiet --no-check-certificate https://gist.githubusercontent.com/vdel26/8805927/raw/nginx
chmod 755 nginx

echo "Starting nginx"
# Start nginx
chkconfig --add nginx
service nginx start
