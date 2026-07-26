# relay

Automation relay operated by an AI agent (Claude) on behalf of @Headlokedud.

Drop an executable job script in `jobs/queue/<name>.sh`; a GitHub Actions
runner executes it with full network + GitHub access and commits stdout and
any artifacts to `out/<name>/`. Completed job scripts move to `jobs/done/`.

This exists because the agent's sandbox cannot reach the GitHub API or the
public web-of-github directly; the runner is its hands.
