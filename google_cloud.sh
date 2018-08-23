if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo 'Ex: "simon says" "/tmp/simon.wav"'
    exit 1
fi

text=${1}
wav=${2}

google_cloud() {
$(curl -s 'https://cxl-services.appspot.com/proxy?url=https%3A%2F%2Ftexttospeech.googleapis.com%2Fv1beta1%2Ftext%3Asynthesize' \
-H 'origin: https://cloud.google.com' \
-H 'accept-encoding: gzip, deflate, br' \
-H 'accept-language: en-US,en;q=0.9,ro;q=0.8' \
-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3450.0 Iron Safari/537.36' \
-H 'content-type: text/plain;charset=UTF-8' \
-H 'accept: */*' \
-H 'referer: https://cloud.google.com/text-to-speech/' \
-H 'authority: cxl-services.appspot.com' --data-binary '{"voice":{"languageCode":"en-US","name":"en-US-Wavenet-F"},"audioConfig":{"audioEncoding":"LINEAR16","pitch":"0.00","speakingRate":"1.00"}, "input":{"text":"'"${text}"'"}}' --compressed | awk -F '"' '{printf $4}' |base64 -d > ${wav})
}

for i in {1..5}; do
  google_cloud
    if [ "$(stat -c %s "$wav")" -gt 100000 ]
    then
      break
    fi
done
