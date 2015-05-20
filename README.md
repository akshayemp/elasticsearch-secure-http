# elasticsearch-secure-http
A HTTP auth secured version of elasticsearch using nginx and Lua, presented as a vagrant file.
## Overview
The aim of this project is to provide a simple example of a HTTP Basic Auth secured elasticsearch instance. It is presented as a Vagrant script to create a virtual machine. This allows everyone to get a test server up and running quickly.
If you are simply looking for instructions, please refer to the bootstrap scripts. Note these are specific to SLES 11 SP3 and probably won't work elsewhere.
This project will create a vagrant virtual machine running the following:
- SuSe Enterprise 11 SP3
- Elasticsearch
- Nginx
- Lua
- Kibana (optional)

# Prerequisites
Please install vagrant from: http://www.vagrantup.com/downloads
# Installation
To install, clone the repository, then run vagrant.
```
git clone https://github.com/philwinder/elasticsearch-secure-http.git
cd elasticsearch-secure-http
vagrant up
```
*WARNING:* The vagrant file pulls down a SLES 11 SP3 image, which is quite large. Make sure you are not being charged!
# Usage
Vagrant will create a virtual machine with the port 8080 forwarded to your local machine. You can then communicate with elasticsearch with a curl request, or through your browser. For example:
```
curl -XGET user:password@localhost:8080/monitor-1234/_search
curl -XPOST dev:password@localhost:8080/log-1234/document/980fdshji -d '{ "field": "Test data" }'
curl -XPOST admin:password@localhost:8080/test/document/9052jkhgd -d '{ "field": "Test data" }'
curl -XDELETE admin:password@localhost:8080/test
```
Note that users without permission are not authorized to do someing bad!
```
curl -XDELETE user:password@localhost:8080/monitor-1234
```
## Users and groups
By default all users have the password "password". Please see the htpasswd file for users. 
The Lua script defines which users (as defined in the htpasswd file) belong to each group. Each group is only allowed certain permissions. Please edit the htpasswd file and the lua script to alter the user definitions or the group permissions.
# Testing
You can run the shell script in the test directory to run some simple unit tests agains the server.
