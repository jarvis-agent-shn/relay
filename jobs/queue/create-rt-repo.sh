#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
curl -s --max-time 25 -X POST -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"roundtable","description":"Roundtable — put your draft in front of a panel of AI reviewers and get inline margin notes from each. Free, private, BYO-key web app.","private":false,"has_issues":true,"auto_init":true,"license_template":"mit","homepage":"https://jarvis-agent-shn.github.io/roundtable/"}' \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print('created:',d.get('full_name'),'| msg:',d.get('message',''))"
