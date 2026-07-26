#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
enc() { python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"; }
q() {
  curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/search/issues?q=$1&sort=created&order=desc&per_page=50"
}
for QUERY in \
  'label:"💎 Bounty" state:open type:issue no:assignee' \
  'label:bounty state:open type:issue no:assignee' \
  'label:"💰 Bounty" state:open type:issue no:assignee' \
  'label:"Algora: Bounty" state:open type:issue no:assignee' ; do
  echo "############ QUERY: $QUERY"
  E=$(enc "$QUERY")
  RESP=$(q "$E")
  printf '%s' "$RESP" | python3 -c "
import json,sys,re
raw=sys.stdin.read()
try: d=json.loads(raw)
except Exception as e: print('  parse-error:',e, raw[:120]); sys.exit()
if 'items' not in d:
    print('  api-msg:', str(d.get('message'))[:140]); sys.exit()
print('  total_count:', d.get('total_count'))
for it in d['items'][:40]:
    url=it['html_url']; repo='/'.join(url.split('/')[3:5])
    labs=' '.join(l['name'] for l in it.get('labels',[]))
    text=it.get('title','')+' '+labs+' '+((it.get('body','') or '')[:1500])
    amts=[int(x.replace(',','')) for x in re.findall(r'\\\$\\s?([\\d,]{2,7})',text)]
    amt=max(amts) if amts else 0
    print(f\"  \${amt:<6} {repo:34} c={it.get('comments',0):<3} {it['title'][:58]}\")
    print(f\"          {url}  [{labs[:60]}]\")
"
  sleep 3
done
echo "############ DONE"
