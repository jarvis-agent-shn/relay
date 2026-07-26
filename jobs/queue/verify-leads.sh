#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
g() { curl -s --max-time 25 -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" "https://api.github.com/$1"; sleep 6; }

show_repo() {
  echo "===== REPO $1 ====="
  g "repos/$1" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if 'full_name' not in d: print('  msg:',str(d.get('message'))[:120]); sys.exit()
o=d.get('owner',{})
print('  full:',d['full_name'],'| owner_type:',o.get('type'))
print('  stars:',d.get('stargazers_count'),'| forks:',d.get('forks_count'),'| created:',d.get('created_at','')[:10],'| pushed:',d.get('pushed_at','')[:10])
print('  lang:',d.get('language'),'| desc:',(d.get('description') or '')[:120])
print('  homepage:',d.get('homepage'))
"
}
show_issue() {
  echo "----- ISSUE $1#$2 -----"
  g "repos/$1/issues/$2" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if 'title' not in d: print('  msg:',str(d.get('message'))[:120]); sys.exit()
print('  title:',d['title'])
print('  state:',d['state'],'| author:',d['user']['login'],'| comments:',d['comments'])
print('  labels:',[l['name'] for l in d['labels']])
print('  --body--'); print((d.get('body') or '')[:1800])
"
}
comments_tail() {
  echo "  --recent comments $1#$2--"
  g "repos/$1/issues/$2/comments?per_page=100" | python3 -c "
import json,sys
c=json.load(sys.stdin); c=c if isinstance(c,list) else []
for x in c[-8:]:
    print('   @%s:'%x['user']['login'], (x.get('body') or '').replace(chr(10),' ')[:200])
print('   (total:',len(c),')')
"
}
closed_bounties() {
  echo "  --recently CLOSED bounty issues in $1 (payout proof?)--"
  g "search/issues?q=repo:$1+label:%22%F0%9F%92%8E%20Bounty%22+state:closed&sort=updated&order=desc&per_page=10" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for it in d.get('items',[])[:10]:
    print('   #%s'%it['number'], it['state'], '|', it['title'][:60])
"
}

echo '############################ CLANKERNATION/OPENAGENTS'
show_repo "ClankerNation/OpenAgents"
show_issue "ClankerNation/OpenAgents" 198
comments_tail "ClankerNation/OpenAgents" 198
closed_bounties "ClankerNation/OpenAgents"

echo; echo '############################ UNSAFELABS/RFC-5322'
show_repo "UnsafeLabs/RFC-5322"
show_issue "UnsafeLabs/RFC-5322" 1
comments_tail "UnsafeLabs/RFC-5322" 1
echo "############ DONE"
