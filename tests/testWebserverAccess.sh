#!/bin/bash

assertOK() {
	response=$(curl -o /dev/null --silent --write-out '%{http_code}\n' -$1 $2 --data "$3")
	if [[ $response == "200" ]] || [[ $response == "201" ]];
        	then echo "[OK-ACCEPTED] $1 $2 $3";
        	else 
			echo "TEST FAILED, should be ok: $1 $2 $3"
			echo "Reason: " 
			echo $(curl --silent -$1 $2 --data "$3")
			exit 1;
	fi	
}

assertDenied() {
        response=$(curl -o /dev/null --silent --write-out '%{http_code}\n' -$1 $2 --data "$3")
        if [[ $response != "200" ]] && [[ $response != "201" ]];
                then echo "[OK-DENIED] $1 $2 $3";
                else
                        echo "TEST FAILED, should be denied: $1 $2 $3"
			echo "Reason: " 
			echo $(curl --silent -$1 $2 --data "$3")
                        exit 1;
        fi
}

# Users are able to search "monitor-" index
assertOK XGET user:password@localhost:8080/monitor-1234/_search

# Users are not able to search "log-" or any other indices
assertDenied XGET user:password@localhost:8080/log-1234/_search
assertDenied XGET user:password@localhost:8080/test/_search

# Users are not allowed to insert/delete data
assertDenied XDELETE user:password@localhost:8080/monitor-1234
assertDenied XPOST user:password@localhost:8080/monitor-1234/document/fhfdsa89 '{"dummy":"data"}'

# Devs are able to search "monitor-" and "log-" indices
assertOK XGET dev:password@localhost:8080/monitor-1234/_search
assertOK XGET dev:password@localhost:8080/log-1234/_search

# Devs are allowed to insert data to log/monitor, but not to a new index
assertOK XPOST dev:password@localhost:8080/monitor-1234/document/fioujkzfx90 '{"dummy":"data"}'
assertDenied XPOST dev:password@localhost:8080/test1/document/9fdas90 '{"dummy":"data"}'

# Admins are allowed to do whatever they like!
assertOK XPOST admin:password@localhost:8080/test/document/98fiuo '{"myField" : "fdaf"}'
assertOK XDELETE admin:password@localhost:8080/test
assertOK XGET admin:password@localhost:8080/log-1234/_search