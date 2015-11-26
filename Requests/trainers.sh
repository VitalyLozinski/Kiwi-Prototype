date -u
curl "http://api.kiwi.beta.linksoftstudio.com/event/trainers" -X POST -H "Content-Type:application/json" -v --data-binary @trainers.json
