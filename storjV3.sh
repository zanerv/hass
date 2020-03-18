#!/bin/bash

if [[ -z $1 ]]; then
    exit 1
fi
api='dashboard'
id(){
    id=$(curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/storagenode/exec -d \
        '{ "AttachStdin":false,"AttachStdout":true,"AttachStderr":true, "Tty":false, "Cmd":["/usr/bin/curl", "-s", "127.0.0.1:14002/api/'${1}'"]}'\
    | jq -r .Id)
}

if [[ ${1} == 'all' ]];then

    id satellites
    curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d \
    '{ "Detach":false,"Tty":true}' --output -|jq -r .data.${2}
    exit 0
elif [[ ${1} == 'bandwidthSummary' ]];then
    id satellites
    curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d \
    '{ "Detach":false,"Tty":true}' --output -|jq -r .data.bandwidthSummary
    exit 0
elif [[ ${1} == 'egressSummary' ]];then
    id satellites
    curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d \
    '{ "Detach":false,"Tty":true}' --output -\
    |jq -r '.data.bandwidthDaily[].egress'\
    |jq -n 'reduce (inputs | to_entries[]) as {$key,$value} ({}; .[$key] += $value)'\
    |jq -r .[]| paste -s -d+ - | bc
    exit 0
elif [[ ${1} == 'egressDaily' ]];then
    id satellites
    curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d \
    '{ "Detach":false,"Tty":true}' --output -|jq -r .data.bandwidthDaily[-1].egress[]| paste -s -d+ - | bc
    exit 0
fi
    id dashboard

curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d \
'{ "Detach":false,"Tty":true}' --output - | jq .data.${1}.used

if [[ $? != 0 ]]; then
    id=$(curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/storagenode/exec -d \
    '{ "AttachStdin":false,"AttachStdout":true,"AttachStderr":true, "Tty":false, "Cmd":["apk", "add", "curl", "jq "]}'|jq -r .Id)
    curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d \
    '{ "Detach":false,"Tty":false}' -o - > /dev/null
fi
