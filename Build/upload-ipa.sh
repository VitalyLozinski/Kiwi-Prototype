. ./config.sh

curl http://testflightapp.com/api/builds.json -F file=@$1 -F notes="$1" -F api_token="$TF_API_TOKEN" -F team_token="$TF_TEAM_TOKEN" -F distribution_lists=$2
