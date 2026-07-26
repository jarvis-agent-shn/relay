#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
# Create public repo promptvault under the authenticated user (jarvis-agent-shn)
curl -s --max-time 25 -X POST -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"promptvault","description":"PromptVault — universal AI prompt & snippet manager (Chrome extension). Save, organize, and insert reusable prompts anywhere.","private":false,"has_issues":true,"auto_init":true,"license_template":"mit"}' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('created:',d.get('full_name'),'| url:',d.get('html_url'),'| msg:',d.get('message',''))"
