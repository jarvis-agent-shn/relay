#!/usr/bin/env bash
set -uo pipefail
TOK="${GH_PAT//[$'\r\n\t ']/}"
curl -s --max-time 25 -X POST -H "Authorization: token ${TOK}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/jarvis-agent-shn/site/pages -d '{"source":{"branch":"main","path":"/"}}' -w "\nHTTP %{http_code}\n" | tail -3
