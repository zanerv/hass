#!/bin/bash
playlist=7708 #Get playlist id: curl -s  http://plex:32400/playlists/all

song=$(curl -s http://${IP}:32400/playlists/$playlist/items \
 |grep "parts"|awk -F '"' '{print "http://'${IP}':32400" $4}'|shuf |head -1)

curl -s -X POST -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" -d '{"attributes": {"friendly_name":  "Plex casting"}, "entity_id": "input_text.url", "state": "'"$song"'"}'\
 http://localhost:8123/api/states/input_text.url >/dev/null 2>&1
