#!/usr/bin/env bash
set -uo pipefail
echo "len GH_PAT: ${#GH_PAT}"
echo "prefix: ${GH_PAT:0:7}"
echo "=== /user raw ==="
curl -s -w "\nHTTP %{http_code}\n" -H "Authorization: Bearer ${GH_PAT}" https://api.github.com/user
echo "=== /rate_limit raw (token scheme) ==="
curl -s -w "\nHTTP %{http_code}\n" -H "Authorization: token ${GH_PAT}" https://api.github.com/rate_limit
