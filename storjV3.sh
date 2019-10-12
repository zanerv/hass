#!/bin/bash

if [[ $1 == "install" ]];then
id=$(curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/storagenode/exec -d '{ "AttachStdin":false,"AttachStdout":true,"AttachStderr":true, "Tty":false, "Cmd":["apk", "add", "curl", "jq "]}'|jq -r .Id)

curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST \
http:/v1.24/exec/${id}/start -d '{ "Detach":false,"Tty":false}' -o - > /dev/null
   exit
elif [[ -z $1 ]]; then
   exit 1
fi

id=$(curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/storagenode/exec -d '{ "AttachStdin":false,"AttachStdout":true,"AttachStderr":true, "Tty":false, "Cmd":["/usr/bin/curl", "-s", "127.0.0.1:14002/api/dashboard"]}' | jq -r .Id)
curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d '{ "Detach":false,"Tty":true}' --output - | jq .data.${1}.used

