date -u
curl "http://api.kiwi.beta.linksoftstudio.com/event" -X POST -H "Content-Type:application/json" -v --data-binary @events.json
