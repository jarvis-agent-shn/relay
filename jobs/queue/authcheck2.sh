#!/usr/bin/env bash
set -uo pipefail
echo "len: ${#GH_PAT} prefix: ${GH_PAT:0:4}"
curl -s -w "\nHTTP %{http_code}\n" -H "Authorization: token ${GH_PAT}" https://api.github.com/user \
  | python3 -c "import json,sys; 
raw=sys.stdin.read()
body=raw.rsplit('HTTP',1)[0]
try:
    d=json.loads(body); print('login:',d.get('login'),'| id:',d.get('id'))
except: print(raw[:200])"
curl -s -H "Authorization: token ${GH_PAT}" https://api.github.com/rate_limit \
  | python3 -c "import json,sys; c=json.load(sys.stdin).get('resources',{}).get('core',{}); print('core limit:',c.get('limit'),'remaining:',c.get('remaining'))"
curl -s -I -H "Authorization: token ${GH_PAT}" https://api.github.com/user | grep -i "^x-oauth-scopes" || echo "no scopes hdr"
