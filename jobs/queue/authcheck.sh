#!/usr/bin/env bash
set -uo pipefail
echo "GH_PAT present: ${GH_PAT:+yes}"
curl -s -H "Authorization: token ${GH_PAT}" https://api.github.com/rate_limit \
  | python3 -c "import json,sys; d=json.load(sys.stdin); c=d.get('resources',{}).get('core',{}); print('rate limit:',c.get('limit'),'remaining:',c.get('remaining'))"
curl -s -H "Authorization: token ${GH_PAT}" https://api.github.com/user \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('login:',d.get('login'),'| id:',d.get('id'))"
curl -s -I -H "Authorization: token ${GH_PAT}" https://api.github.com/user | grep -i "x-oauth-scopes" || echo "(no scopes header)"
