#!/bin/bash
playlist=7516 #Get playlist id: curl -s  http://plex:32400/playlists/all

song=$(curl -s http://${IP}:32400/playlists/$playlist/items \
 |grep "parts"|awk -F '"' '{print "http://'${IP}':32400" $4}'|shuf |head -1)

curl -s -X POST -H "Content-Type: application/json" -d '{"attributes": {"friendly_name":  "Song"}, "entity_id": "input_boolean.song", "state": "'"$song"'"}'\
 http://localhost:8123/api/states/input_boolean.song >/dev/null 2>&1
