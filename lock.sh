#!/bin/bash
log="/storage/sdcard0/Android/data/com.xiaomi.smarthome/files/SherlockLog/$(date +%Y%m%d.log)"

if [[ ${1} == "unlock" ]]; then
    adb shell 'dumpsys input_method | grep mScreenOn=true || input keyevent 26'
    sleep 0.2
    adb shell input swipe 360 1000 580 1000
elif [[ ${1} == "lock" ]]; then
    adb shell 'dumpsys input_method | grep mScreenOn=true || input keyevent 26'
    sleep 0.2
    adb shell input swipe 360 1000 150 1000
elif [[ ${1} == "fake" ]]; then
    adb shell "echo 'mOperateCommandType:Unlock' >> ${log}"
fi

sleep 5

lock=$(adb shell cat ${log}|grep mOperateCommandType|tail -1| grep -oP '(?<=mOperateCommandType:).*?(?=\r)'||echo unknown)

if [[ ${lock} =~ "unknown" ]] ; then
    adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png /config/www/
    curl --silent --output /dev/null -X POST -H "Authorization: Bearer $HASS_TOKEN" \
    -H "Content-Type: application/json" -d '{"title": "Door","message": "Unknown state"}' \
    http://localhost:8123/api/services/notify/hass
fi

curl -s -X POST -H "Authorization: Bearer $HASS_TOKEN" -H "Content-Type: application/json" \
 -d '{"attributes": {"friendly_name":  "Door lock"}, "entity_id": "sensor.door_lock", "state": "'"$lock"'"}'\
 http://localhost:8123/api/states/sensor.door_lock >/dev/null 2>&1

adb shell 'dumpsys input_method | grep mScreenOn=false || input keyevent 26'

#unlock, start app, screencap and pull it
#adb shell 'dumpsys input_method | grep mScreenOn=true || input keyevent 26'&&sleep 2&&  adb shell input tap 103 147&&sleep 2&&  adb shell screencap -p /sdcard/screencap.png&&adb pull /sdcard/screencap.png
