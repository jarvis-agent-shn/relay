#!/usr/bin/env bash
set -uo pipefail
AUTH="Authorization: token ${GH_PAT}"
api() { curl -s -H "$AUTH" -H "Accept: application/vnd.github+json" "$@"; }
python3 - <<'PY'
import json, urllib.request, time, os, re
PAT=os.environ["GH_PAT"]
def search(q, sort="created", order="desc", per=50):
    url="https://api.github.com/search/issues?q="+urllib.parse.quote(q)+f"&sort={sort}&order={order}&per_page={per}"
    req=urllib.request.Request(url, headers={"Authorization":f"token {PAT}","Accept":"application/vnd.github+json","User-Agent":"jarvis"})
    with urllib.request.urlopen(req,timeout=30) as r: return json.load(r)
import urllib.parse
queries=[
  'label:"💎 Bounty" state:open type:issue no:assignee',
  'label:"💵 Bounty" state:open type:issue no:assignee',
  'label:bounty state:open type:issue no:assignee',
  'Algora bounty state:open type:issue in:body no:assignee',
]
seen={}
for q in queries:
    try:
        d=search(q)
    except Exception as e:
        print("query failed:",q,e); time.sleep(3); continue
    print(f"\n### query: {q}  (total_count={d.get('total_count')})")
    for it in d.get("items",[])[:40]:
        url=it["html_url"]
        if url in seen: continue
        seen[url]=1
        # extract $ amounts from title+labels+body
        text=(it.get("title","")+" "+" ".join(l["name"] for l in it.get("labels",[]))+" "+(it.get("body","") or ""))[:2000]
        amts=[int(x.replace(",","")) for x in re.findall(r'\$\s?([\d,]{2,7})', text)]
        amt=max(amts) if amts else 0
        repo="/".join(url.split("/")[3:5])
        print(f"  ${amt:<6} {repo:32} c={it.get('comments',0):<3} {it['title'][:60]}")
        print(f"         {url}")
    time.sleep(2)
print(f"\nunique issues: {len(seen)}")
PY
