#!/usr/bin/env bash
# Fresh-bounty monitor. Scans proven-paying orgs for OPEN, UNASSIGNED 💎 bounties,
# writes a ranked snapshot to out/monitor-bounties/. Compare across runs to spot NEW ones.
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
srch() {
  curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/search/issues?q=$1&per_page=40&sort=created&order=desc"
  sleep 8
}
enc() { python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"; }

# Proven-paying orgs (expand as we verify more). activepieces is the workhorse.
ORGS="activepieces documenso calcom twentyhq novuhq triggerdotdev coderabbitai formbricks unkeyed windmill-labs maybe-finance trigms teableio zed-industries"

echo "=== fresh-bounty monitor $(date -u) ==="
for ORG in $ORGS; do
  Q=$(enc "org:${ORG} label:\"💎 Bounty\" state:open type:issue no:assignee")
  printf '%s' "$(srch "$Q")" | ORG="$ORG" python3 -c "
import json,sys,re,os
org=os.environ['ORG']; raw=sys.stdin.read()
try: d=json.loads(raw)
except: print(f'[{org}] parse-err'); sys.exit()
if 'items' not in d: sys.exit()
for it in d['items']:
    labs=' '.join(l['name'] for l in it.get('labels',[]))
    if 'Rewarded' in labs: continue  # already paid
    amts=[int(x.replace(',','')) for x in re.findall(r'\\\$\s?([\d,]{2,7})', it['title']+' '+labs)]
    amt=max(amts) if amts else 0
    print(f\"OPEN \${amt:<5} {org}/{it['html_url'].split('/')[4]}#{it['number']} c={it['comments']} {it['title'][:50]} | {it['html_url']}\")
"
done
echo "=== end monitor ==="
