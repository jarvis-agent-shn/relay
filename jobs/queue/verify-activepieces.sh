#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
g() { curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" "https://api.github.com/$1"; sleep 7; }

echo "===== activepieces/activepieces repo ====="
g "repos/activepieces/activepieces" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print('stars:',d.get('stargazers_count'),'| forks:',d.get('forks_count'),'| pushed:',d.get('pushed_at','')[:10],'| lang:',d.get('language'),'| license:',(d.get('license') or {}).get('spdx_id'),'| open_issues:',d.get('open_issues_count'))
"
echo "===== issue #8072 full ====="
g "repos/activepieces/activepieces/issues/8072" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print('title:',d['title'])
print('state:',d['state'],'| assignees:',[a['login'] for a in d['assignees']],'| comments:',d['comments'],'| author:',d['user']['login'])
print('labels:',[l['name'] for l in d['labels']])
print('created:',d['created_at'][:10],'updated:',d['updated_at'][:10])
print('--body--'); print((d.get('body') or '')[:2500])
"
echo "===== ALL comments on #8072 (claim/assignment signals) ====="
g "repos/activepieces/activepieces/issues/8072/comments?per_page=100" | python3 -c "
import json,sys; c=json.load(sys.stdin); c=c if isinstance(c,list) else []
for x in c:
    print('@%s (%s):'%(x['user']['login'],x['created_at'][:10]), (x.get('body') or '').replace(chr(10),' ')[:240])
print('total comments:',len(c))
"
echo "===== activepieces payout track record: recently closed 💎 bounties ====="
g "search/issues?q=repo:activepieces/activepieces+label:%22%F0%9F%92%8E%20Bounty%22+state:closed&sort=updated&order=desc&per_page=15" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print('closed bounty count (approx):',d.get('total_count'))
for it in d.get('items',[])[:15]:
    labs=' '.join(l['name'] for l in it.get('labels',[]))
    print('  #%s'%it['number'], it['title'][:50],'| rewarded' if 'Rewarded' in labs or '💰' in labs else '| ?', '|',labs[:50])
"
echo "===== how activepieces bounties work (CONTRIBUTING / bounty docs) ====="
g "repos/activepieces/activepieces/contents/CONTRIBUTING.md" | python3 -c "
import json,sys,base64
d=json.load(sys.stdin)
if 'content' in d:
    t=base64.b64decode(d['content']).decode('utf-8','ignore')
    import re
    for m in re.finditer(r'.{0,80}(bounty|bounties|algora|reward).{0,160}', t, re.I):
        print('  ...',m.group(0).replace(chr(10),' ')[:240])
else: print('  no CONTRIBUTING.md:', str(d.get('message'))[:60])
"
echo "############ DONE"
