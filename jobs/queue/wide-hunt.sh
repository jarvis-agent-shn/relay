#!/usr/bin/env bash
# Global bounty hunt: recent open 💎 Bounty issues, filtered to REPUTABLE repos (stars>=400),
# unassigned, low competition. Catches any legit payer regardless of org guess.
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
api() { curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" "https://api.github.com/$1"; }

python3 - <<'PY'
import json, urllib.request, urllib.parse, os, time, re
TOK=os.environ["GH_PAT"].strip()
def get(path):
    req=urllib.request.Request("https://api.github.com/"+path,
        headers={"Authorization":f"token {TOK}","Accept":"application/vnd.github+json","User-Agent":"jarvis"})
    with urllib.request.urlopen(req,timeout=30) as r: return json.load(r)

BLOCK=("securebananalabs","bounty-plaza","clankernation","unsafelabs","xevrion","tg-station",
       "relayhop","zhangjiayang","iamgoofball","oss-hunter","jaasielitaigq","lh-standard","bugb")

# pull several pages of recent open bounty issues
issues=[]
for page in range(1,5):
    q=urllib.parse.quote('label:"💎 Bounty" state:open type:issue no:assignee')
    try:
        d=get(f"search/issues?q={q}&per_page=50&sort=created&order=desc&page={page}")
    except Exception as e:
        print("search err",e); break
    items=d.get("items",[])
    issues+=items
    if len(items)<50: break
    time.sleep(7)
print(f"scanned {len(issues)} recent open unassigned bounty issues\n")

star_cache={}
def stars(repo):
    if repo in star_cache: return star_cache[repo]
    try:
        r=get("repos/"+repo); s=r.get("stargazers_count",0); star_cache[repo]=(s,r.get("pushed_at","")[:10]);
    except Exception: star_cache[repo]=(-1,"?")
    time.sleep(5)
    return star_cache[repo]

cands=[]
for it in issues:
    labs=" ".join(l["name"] for l in it.get("labels",[]))
    if "Rewarded" in labs: continue
    url=it["html_url"]; repo="/".join(url.split("/")[3:5])
    low=repo.lower()
    if any(b in low for b in BLOCK): continue
    if it.get("comments",0)>10: continue   # heavy competition
    amts=[int(x.replace(",","")) for x in re.findall(r'\$\s?([\d,]{2,7})', it["title"]+" "+labs)]
    amt=max(amts) if amts else 0
    cands.append((amt,repo,it["number"],it.get("comments",0),it["title"],url))

# star-filter the candidates (limit calls to top ~30 by amount)
cands.sort(key=lambda c:-c[0])
print("=== REPUTABLE, low-competition, unassigned open bounties ===")
shown=0
for amt,repo,num,c,title,url in cands[:35]:
    s,pushed=stars(repo)
    if s<400: continue
    print(f"${amt:<6} ★{s:<6} c={c:<2} pushed={pushed} {repo}#{num}  {title[:52]}")
    print(f"        {url}")
    shown+=1
print(f"\n{shown} reputable candidates (of {len(cands)} passing basic filters)")
PY
echo "############ DONE"
