#!/bin/bash

#!/bin/bash
id=$(curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/storagenode/exec -d '{ "AttachStdin":false,"AttachStdout":true,"AttachStderr":true, "Tty":false, "Cmd":["/usr/bin/curl", "-s", "127.0.0.1:14002/api/dashboard"]}' | jq -r .Id)
curl -s -H "Content-Type: application/json" --unix-socket /var/run/docker.sock -X POST http:/v1.24/exec/${id}/start -d '{ "Detach":false,"Tty":true}' --output - | jq .data.diskSpace.used

