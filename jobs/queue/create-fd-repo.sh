#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
curl -s --max-time 25 -X POST -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"foldly","description":"Foldly — organize your ChatGPT, Claude & Gemini conversations into folders, pin favorites, and search. Chrome extension.","private":false,"has_issues":true,"auto_init":true,"license_template":"mit"}' \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print('created:',d.get('full_name'),'| msg:',d.get('message',''))"
