#!/bin/bash

today="24h"

yesterday="48h and time < now() - 24h"

extract(){
for i in {0..2}
  do
   bytes=$(curl -s -G 'http://influxdb:8086/query?pretty=true' --data-urlencode "db=collectd" --data-urlencode \
   "q=SELECT sum(\"value\") FROM \"storj_value\" WHERE \"type\" = 'shared' AND \"type_instance\" =~ /.*/ \
   AND time >= now() - $@ GROUP BY time(60s)  order by desc limit 3"|jq .results[0].series[0].values[${i}][1])
   if [[ $bytes != "null" ]]
     then
       echo "${bytes}"
     break
   fi
done
}

bytes_today=$(extract "${today}")

bytes_yesterday=$(extract "${yesterday}")

bytes_diff=$(expr  $bytes_today - $bytes_yesterday)

increase=$(expr $bytes_diff / 1024 / 1024 / 1024)
increase+="GB"
curl -s -X POST -H "Content-Type: application/json" -d '{"attributes": {"friendly_name":  "Storj increase", "icon": "mdi:nas"}, "entity_id": "sensor.storj", "state": "'"$increase"'"}'  http://localhost:8123/api/states/sensor.storj

