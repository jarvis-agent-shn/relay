#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
python3 - <<'PY'
import json, urllib.request, urllib.parse, os, time
TOK=os.environ["GH_PAT"].strip()
def get(path):
    req=urllib.request.Request("https://api.github.com/"+path,
        headers={"Authorization":f"token {TOK}","Accept":"application/vnd.github+json","User-Agent":"jarvis"})
    with urllib.request.urlopen(req,timeout=30) as r: return json.load(r)

# 1) activepieces bounty posting cadence (open+closed 💎 Bounty, by creation date)
q=urllib.parse.quote('repo:activepieces/activepieces label:"💎 Bounty"')
d=get(f"search/issues?q={q}&per_page=50&sort=created&order=desc")
print("activepieces total 💎 bounties:", d.get("total_count"))
items=d.get("items",[])
print("most recent 25 by created:")
from datetime import datetime
dates=[]
for it in items[:25]:
    st="OPEN " if it["state"]=="open" else "closed"
    labs=" ".join(l["name"] for l in it["labels"])
    rew="💰" if "Rewarded" in labs else "  "
    print(f"  {it['created_at'][:10]} {st} {rew} #{it['number']} {it['title'][:46]}")
    dates.append(it['created_at'][:10])
if len(dates)>=2:
    d0=datetime.fromisoformat(dates[0]); d1=datetime.fromisoformat(dates[-1])
    span=(d0-d1).days or 1
    print(f"\n  => {len(dates)} bounties over {span} days = ~{len(dates)/span*7:.1f}/week (recent)")
time.sleep(6)

# 2) do other automation platforms run bounties? quick probes
print("\n=== other platforms: open bounty-ish labels ===")
for repo in ["n8n-io/n8n","PipedreamHQ/pipedream","huginn/huginn","windmill-labs/windmill",
             "activepieces/activepieces","automatisch/automatisch","Kestra-io/kestra"]:
    total=0
    for lab in ['"💎 Bounty"','bounty','"Algora: Bounty"']:
        try:
            qq=urllib.parse.quote(f'repo:{repo} label:{lab} state:open')
            r=get(f"search/issues?q={qq}&per_page=1")
            total+=r.get("total_count",0)
        except Exception as e:
            pass
        time.sleep(4)
    print(f"  {repo:32} open bounty-labeled issues: {total}")
PY
echo "############ DONE"
