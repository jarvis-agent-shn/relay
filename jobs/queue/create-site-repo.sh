#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
curl -s --max-time 25 -X POST -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"site","description":"Sidenote Tools — small, private browser tools for AI power users. Marketing site.","private":false,"has_issues":false,"auto_init":true}' \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print('created:',d.get('full_name'),'| msg:',d.get('message',''))"
