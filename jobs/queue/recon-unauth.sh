#!/usr/bin/env bash
set -uo pipefail
gh_get() { curl -s "https://api.github.com/$1"; }  # public, no auth
for spec in "uswriting/zeroperl/issues/7|zeroperl \$1500" "go-gitea/gitea/issues/24635|gitea \$1880"; do
  path="${spec%%|*}"; label="${spec##*|}"
  echo "############ $label  ($path)"
  gh_get "repos/$path" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('title :',d.get('title'))
print('state :',d.get('state'),'| comments:',d.get('comments'),'| labels:',[l['name'] for l in d.get('labels',[])])
print('user  :',(d.get('user') or {}).get('login'))
print('assignees:',[a['login'] for a in d.get('assignees',[])])
print('--- body ---'); print((d.get('body') or '')[:2500])
"
  repo="${path%/issues/*}"
  echo "--- repo meta ($repo) ---"
  gh_get "repos/$repo" | python3 -c "import json,sys; d=json.load(sys.stdin); print('lang:',d.get('language'),'| stars:',d.get('stargazers_count'),'| pushed:',d.get('pushed_at'),'| open_issues:',d.get('open_issues_count'),'| license:',(d.get('license') or {}).get('spdx_id'))"
  echo "--- recent comments ---"
  gh_get "repos/$path/comments?per_page=100" | python3 -c "
import json,sys
c=json.load(sys.stdin)
c=c if isinstance(c,list) else []
for x in c[-6:]:
    print('  @%s:'%x['user']['login'], (x.get('body') or '').replace(chr(10),' ')[:200])
print('  (total comments fetched: %d)'%len(c))
"
  echo
done
