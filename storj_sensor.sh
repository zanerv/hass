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

bytesToHuman() {
increase=""
  if [[ ${1} =~ "-" ]]
   then
    a=${1/-/}
    increase="-"
   else
    a=${1}
  fi
    b=${a:-0}; d=''; s=0; S=(Bytes {K,M,G,T,P,E,Z,Y}B)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        let s++
    done
    increase=$increase"$b$d${S[$s]}"
echo $increase
}

bytes_today=$(extract "${today}")

bytes_yesterday=$(extract "${yesterday}")

bytes_diff=$(expr  $bytes_today - $bytes_yesterday)

if [[ ${1} =~ "-" ]]
	then
		a=${1/-/}
		increase="-"
	else
		a=${1}
fi

bytesToHuman "${bytes_diff}"
curl -s -X POST -H "Content-Type: application/json" -d '{"attributes": {"friendly_name":  "Storj increase", "icon": "mdi:nas"}, "entity_id": "sensor.storj", "state": "'"$increase"'"}'  http://localhost:8123/api/states/sensor.storj >/dev/null 2>&1

