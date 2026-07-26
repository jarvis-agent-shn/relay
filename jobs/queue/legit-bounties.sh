#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
srch() {
  curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/search/issues?q=$1&per_page=30&sort=updated&order=desc"
  sleep 9
}
enc() { python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"; }

# Curated orgs known to run real, paid Algora/Opire bounties on real products.
ORGS="calcom documenso twentyhq tembo-io novuhq triggerdotdev coderabbitai highlight activepieces formbricks unkeyed mudler PostHog appflowyio maybe-finance windmill-labs"

for ORG in $ORGS; do
  Q=$(enc "org:${ORG} label:\"💎 Bounty\" state:open type:issue")
  RESP=$(srch "$Q")
  printf '%s' "$RESP" | ORG="$ORG" python3 -c "
import json,sys,re,os
org=os.environ.get('ORG','?')
raw=sys.stdin.read()
try: d=json.loads(raw)
except Exception as e: print(f'[{org}] parse-error {e}'); sys.exit()
if 'items' not in d:
    print(f'[{org}] api:', str(d.get('message'))[:80]); sys.exit()
n=d.get('total_count',0)
if n==0: print(f'[{org}] no open 💎 bounties'); sys.exit()
print(f'[{org}] total_count={n}')
for it in d['items'][:15]:
    url=it['html_url']; repo='/'.join(url.split('/')[3:5])
    labs=' '.join(l['name'] for l in it.get('labels',[]))
    text=it.get('title','')+' '+labs
    amts=[int(x.replace(',','')) for x in re.findall(r'\\\$\\s?([\\d,]{2,7})',text)]
    amt=max(amts) if amts else 0
    print(f'   \${amt:<6} {repo:26} c={it.get(\"comments\",0):<3} u={it[\"updated_at\"][:10]} {it[\"title\"][:52]}')
    print(f'          {url}  [{labs[:55]}]')
"
done
echo "############ DONE"
