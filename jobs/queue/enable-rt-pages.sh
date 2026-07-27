#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
echo "--- enable GitHub Pages (main / root) ---"
curl -s --max-time 25 -X POST -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/jarvis-agent-shn/roundtable/pages \
  -d '{"source":{"branch":"main","path":"/"}}' \
  -w "\nHTTP %{http_code}\n" | head -20
echo "--- get pages status ---"
curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/jarvis-agent-shn/roundtable/pages \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print('url:',d.get('html_url'),'| status:',d.get('status'),'| msg:',d.get('message',''))"
