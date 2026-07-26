#!/usr/bin/env bash
set -uo pipefail
# Pull live Opire board, cross-check each GitHub issue for real winnability.
python3 - <<'PY'
import json, urllib.request, time

def get(url, auth=False):
    req = urllib.request.Request(url, headers={"User-Agent":"Mozilla/5.0","Accept":"application/json"})
    try:
        with urllib.request.urlopen(req, timeout=25) as r:
            return json.load(r), r.status
    except Exception as e:
        return None, getattr(e, 'code', str(e))

# 1) Opire board
items=[]; off=0
while True:
    b,_=get(f"https://api.opire.dev/rewards?limit=100&offset={off}")
    if not b: break
    items+=b
    if len(b)<100: break
    off+=100
    if off>500: break
print(f"Opire rewards fetched: {len(items)}\n")

rows=[]
for it in items:
    price=(it.get("pendingPrice") or {}).get("value",0)/100
    url=it.get("url","")  # github issue url
    if "github.com" not in url:
        continue
    # parse owner/repo/issues/N
    try:
        parts=url.split("github.com/")[1].split("/")
        owner,repo,num=parts[0],parts[1],parts[3]
    except Exception:
        continue
    iss,st=get(f"https://api.github.com/repos/{owner}/{repo}/issues/{num}")
    if not iss or not iss.get("title"):
        rows.append((price,"DEAD","repo/issue 404",owner+"/"+repo+"#"+num,url)); continue
    state=iss.get("state")
    is_pr = "pull_request" in iss
    labels=[l["name"] for l in iss.get("labels",[])]
    assignees=[a["login"] for a in iss.get("assignees",[])]
    ncom=iss.get("comments",0)
    # repo liveness
    rp,_=get(f"https://api.github.com/repos/{owner}/{repo}")
    pushed=(rp or {}).get("pushed_at","?")
    lang=(rp or {}).get("language","?")
    stars=(rp or {}).get("stargazers_count","?")
    verdict="OPEN" if state=="open" and not is_pr else state.upper()
    rows.append((price,verdict,f"lang={lang} stars={stars} pushed={pushed[:10]} assignees={assignees} comments={ncom}",owner+"/"+repo+"#"+num,url))
    time.sleep(0.3)

rows.sort(key=lambda r:-r[0])
print("PRICE   VERDICT  DETAIL")
for price,verdict,detail,slug,url in rows:
    print(f"${price:>6.0f} {verdict:<7} {slug}")
    print(f"        {detail}")
    print(f"        {url}")
print("\n=== OPEN + LIVE shortlist ===")
for price,verdict,detail,slug,url in rows:
    if verdict=="OPEN" and price>=50:
        print(f"${price:>6.0f}  {slug}  | {detail}")
PY
