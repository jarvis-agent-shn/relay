#!/usr/bin/env bash
set -uo pipefail
echo "### secret / identity check"
if [ -z "${GH_PAT:-}" ]; then echo "GH_PAT NOT SET"; else echo "GH_PAT present (len=${#GH_PAT})"; fi
echo "whoami via API:"; curl -s -H "Authorization: token ${GH_PAT:-none}" https://api.github.com/user | grep -E '"login"|"message"' | head -2
echo
echo "### bounty issue: uswriting/zeroperl#7 (\$1500)"
curl -s -H "Authorization: token ${GH_PAT:-none}" https://api.github.com/repos/uswriting/zeroperl/issues/7 \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('title:',d.get('title')); print('state:',d.get('state')); print('comments:',d.get('comments')); print('labels:',[l['name'] for l in d.get('labels',[])]); print('body:'); print((d.get('body') or '')[:1500])" 2>&1 | head -60
echo
echo "### repo meta zeroperl"
curl -s -H "Authorization: token ${GH_PAT:-none}" https://api.github.com/repos/uswriting/zeroperl \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('lang:',d.get('language'),'stars:',d.get('stargazers_count'),'pushed:',d.get('pushed_at'),'open_issues:',d.get('open_issues_count'))" 2>&1
echo
echo "### bounty issue: go-gitea/gitea#24635 (\$1880)"
curl -s -H "Authorization: token ${GH_PAT:-none}" https://api.github.com/repos/go-gitea/gitea/issues/24635 \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('title:',d.get('title')); print('state:',d.get('state')); print('comments:',d.get('comments')); print('labels:',[l['name'] for l in d.get('labels',[])]); print('body:'); print((d.get('body') or '')[:1200])" 2>&1 | head -50
