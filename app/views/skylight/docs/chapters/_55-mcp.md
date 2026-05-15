---
title: MCP Integration
description: Wire Skylight performance data into AI coding assistants via Model Context Protocol
---

<%= render layout: "note", locals: { type: "important" } do %>
  MCP integration is in Beta! Expect breaking changes between releases and evolving tool shapes. We’d love to hear what’s working for you and what isn’t — see <%= link_to "Feedback", "#feedback" %> below.
<% end %>

The Skylight MCP server reveals your application’s performance data to AI coding assistants like Claude Code, Cursor, Zed, and Codex. Ask your assistant things like "why is this endpoint slow?" or "what regressed in the last deploy?" and have it pull live data straight from Skylight.

## Setup and Configuration

### Install the gem

**Requires Ruby 3.0 or later.** Check with `ruby -v`. If you're on the macOS system Ruby (typically 2.6 or 2.7), install a current Ruby via Homebrew or a version manager ([rbenv](https://github.com/rbenv/rbenv), [asdf](https://asdf-vm.com/), rvm) before continuing.
The config snippets shown below use `gem exec`, which needs RubyGems 3.5 or later (ships with Ruby 3.3+). If `gem --version` shows <3.5, run `gem update --system`.

```
gem install skylight-mcp
```

The gem ships with a precompiled native binary for your platform. Supported:

- **macOS:** `arm64-darwin`, `x86_64-darwin`
- **Linux (glibc):** `x86_64-linux-gnu`, `aarch64-linux-gnu`
- **Linux (musl):** `x86_64-linux-musl`, `aarch64-linux-musl` (e.g., Alpine)
- **FreeBSD:** `x86_64-freebsd`
- **Windows:** not supported directly — use WSL2, which installs the Linux glibc variant.

Then generate an app token at [skylight.io/app/settings/mcp](https://www.skylight.io/app/settings/mcp).

### Claude Code

```
skylight-mcp init --harness claude_code --token <APP_TOKEN>
```

This delegates to `claude mcp add` under the hood, so it respects
`CLAUDE_CONFIG_DIR` and multi-account setups.

### Other MCP harnesses (Cursor, Claude Desktop, Zed, Codex, …)

```
skylight-mcp init --token <APP_TOKEN>
```

Prints a JSON snippet, a TOML snippet, and known harness config-file locations.
Paste the snippet into your harness's MCP config. Sample snippets are below —
your `init --harness manual` output is authoritative if the two ever diverge.

### Sample JSON config (Claude Desktop, Cursor, Zed, …)

Paste under the `mcpServers` key of your harness config:

```json
"skylight": {
  "command": "gem",
  "args": ["exec", "skylight-mcp", "--token", "<YOUR_TOKEN>"]
}
```

Common harness config locations:

- **Claude Desktop:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Cursor:** `~/.cursor/mcp.json` (or per-project `.cursor/mcp.json`)
- **Zed:** `~/.config/zed/settings.json` (under `context_servers`)

### Sample TOML config (Codex)

Append to `~/.codex/config.toml`:

```toml
[mcp_servers.skylight]
command = "gem"
args = ["exec", "skylight-mcp", "--token", "<YOUR_TOKEN>"]
```

### Why `gem exec`?

The generated harness entries launch the server via `gem exec skylight-mcp`, not the `skylight-mcp` shim directly. `gem exec` resolves the currently-installed gem at launch time, so when you later run `gem update skylight-mcp`, the next time your AI client restarts it picks up the new version automatically — no re-running `init`, no stale path inside the harness config.

### Optional: skip the RubyGems update check

`gem exec` may reach out to `rubygems.org` on startup to check for a newer version of `skylight-mcp`. To disable this check, add `--conservative` to the args. `gem exec --conservative` will use whatever version is locally installed, and only hit the network if the gem is missing entirely:

```json
"skylight": {
  "command": "gem",
  "args": ["exec", "--conservative", "skylight-mcp", "--token", "<YOUR_TOKEN>"]
}
```

```toml
[mcp_servers.skylight]
command = "gem"
args = ["exec", "--conservative", "skylight-mcp", "--token", "<YOUR_TOKEN>"]
```

Tradeoff: you'll need to restart your AI client after `gem update skylight-mcp` for the new version to be picked up (which you'd want to do anyway).

### Auto-shutdown behavior

The MCP server idles down after 30 minutes of inactivity (configurable with `--timeout <minutes>` in the harness config args). Your AI client transparently restarts it on next use—you may notice a brief cold-start delay after a long idle period, but no action is required.

### Enabling logs

The MCP server is silent by default. To enable structured (JSON) logs for debugging, add `--log-file <path>` to the harness config args:

```json
"skylight": {
  "command": "gem",
  "args": ["exec", "skylight-mcp", "--token", "<YOUR_TOKEN>", "--log-file", "/tmp/skylight-mcp.log"]
}
```

Pair with `--debug` for verbose output.

### Updating

```
gem update skylight-mcp
# restart your AI client
```

Because the harness entry uses `gem exec`, nothing else needs to change.

### Uninstalling

```
# Claude Code users:
claude mcp remove skylight --scope user

# Everyone:
gem uninstall skylight-mcp
```

## Workflows

Once the server is wired up, your AI assistant can answer performance questions about your app by calling the MCP tools listed below. We highly recommend running `skylight-mcp` in your app's source code directory — your agent can correlate source locations, controller actions, and view templates with Skylight trace data, and suggest code fixes or additional instrumentation blocks based on its findings. A few workflows we've found useful:

### "Why is this endpoint slow?"

Ask your assistant to look at a specific endpoint (or the worst ones on your app). The assistant calls `list_endpoints` to see what's slow, then `get_endpoint_detail` to pull the aggregate trace, then drills into the hot path with `get_trace_node_detail` until it finds the culprit — typically an N+1 query, a slow SQL statement, or a synchronous external call.

Example prompt:

> Using the Skylight MCP tools, find the slowest endpoint on my app right now and explain what's making it slow.

### "Did the last deploy regress performance?"

Ask the assistant to compare current latency to before the most recent deploy. It pulls deploy metadata with `list_deploys`, then uses `get_latency_trends` to pull time-series data for the endpoints you care about, and reports regressions.

Example prompt:

> We deployed about an hour ago. Did anything regress?

If you have deploy tracking and source locations enabled, the assistant can automatically analyze code changes and purposefully inspect the endpoints expected to have changed.

### "What's the trend on this endpoint over the last week?"

`get_latency_trends` returns a time series you can ask the assistant to summarize or flag anomalies in.

Example prompt:

> Pull the last 7 days of latency trends for `UsersController#index` and tell me if there are any obvious anomalies or trends.

### Working with multiple components & environments

For multi-component apps, the assistant can call `list_components` and `select_component` to switch which component subsequent tool calls are scoped to. Generally this process is automatic - most assistants can tell whether a particular question or code snippet belongs to a web or background job component, and will switch between them as needed. If your app has multiple background job components, you may need to direct it to use a particular one.

Environments are assumed to be `production`, though you can select any environment visible in the Skylight UI - just ask your assistant to switch to `staging` for example.

### Extended example: chasing N+1s in a worker

A real Claude Code session, asking it to triage N+1s across production workers and then drill into the worst offender:

<style>
  .mcp-chat-user {
    background: #eef4ff;
    border-left: 3px solid #3b6ef5;
    color: #1e3a8a;
    padding: 0.75em 1em;
    margin: 0.5em 0;
    overflow-x: auto;
    font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    font-size: 0.9em;
    white-space: pre;
  }
</style>

<pre class="mcp-chat-user">❯ Using Skylight, help me find workers with n+1 queries</pre>

```
  Called skylight 5 times (ctrl+o to expand)

⏺ Here are the workers with N+1 query inspections in the last 24h
  on Direwolf (worker:production):

  ┌─────┬─────────────────────────────────────────────────┬─────────┬─────────┬──────────────────────────┐
  │  #  │                     Worker                      │  Count  │   P95   │       Inspections        │
  ├─────┼─────────────────────────────────────────────────┼─────────┼─────────┼──────────────────────────┤
  │ 1   │ UsageWorker (low)                               │ 365,330 │   894ms │ N+1, high-alloc          │
  ├─────┼─────────────────────────────────────────────────┼─────────┼─────────┼──────────────────────────┤
  │ 2   │ IntercomSyncUserWorker (default)                │  15,237 │ 1,237ms │ N+1 (severe)             │
  ├─────┼─────────────────────────────────────────────────┼─────────┼─────────┼──────────────────────────┤
  │ 3   │ GithubRepoAccessWorker (low)                    │   7,728 │ 4,607ms │ N+1                      │
  ├─────┼─────────────────────────────────────────────────┼─────────┼─────────┼──────────────────────────┤
  │ 4   │ StripeWebhookWorker (default)                   │   1,469 │ 5,383ms │ N+1                      │
  ├─────┼─────────────────────────────────────────────────┼─────────┼─────────┼──────────────────────────┤
  │ 9   │ StripeUsageWorker (default)                     │ 365,329 │   353ms │ N+1 (severe), high-alloc │
  ├─────┼─────────────────────────────────────────────────┼─────────┼─────────┼──────────────────────────┤
  │ 20  │ Trends::ComponentReportGeneratorWorker (trends) │  26,772 │   223ms │ N+1 (severe)             │
  └─────┴─────────────────────────────────────────────────┴─────────┴─────────┴──────────────────────────┘

  View in Skylight:
  https://www.skylight.io/app/applications/exampleAppId/recent/24h/endpoints

  Biggest impact candidates (volume × severity):
  - UsageWorker and StripeUsageWorker — ~365k calls/day each,
    both flagged
  - IntercomSyncUserWorker — severe N+1, >1s p95
  - StripeWebhookWorker — 5.4s p95 is rough even at low volume

  Want me to drill into one of these to identify the offending query?
```

<pre class="mcp-chat-user">❯ Yes, let's look at Intercom</pre>

```
  Called skylight (ctrl+o to expand)

⏺ Lots of N+1s. The worst by volume is #46 (billing_periods,
  up to 54 queries per job). Let me get the SQL and source location
  for the biggest offenders.

  Read 2 files, called skylight 5 times (ctrl+o to expand)

⏺ Here's what I found. All the N+1s originate in
  Intercom#sync_user iterating over a user's organizations
  without preloading, then companies_properties firing multiple
  per-org queries.

  Root cause

  lib/direwolf/services/intercom.rb:47:
  organizations = user.apps
    .includes(:organization)
    .map(&:organization).compact.uniq | [organization].compact

  Only :organization is preloaded. Everything inside the
  companies_properties(organizations) loop (intercom.rb:157)
  then hits the DB per org.

  The offenders (per org × up to ~12 orgs)

  ┌──────────┬──────────────────────────────────────────────────┬───────────────────────────┬───────────────────────────────────────────────────────────────┐
  │   Node   │                      Query                       │          Source           │                          Root cause                           │
  ├──────────┼──────────────────────────────────────────────────┼───────────────────────────┼───────────────────────────────────────────────────────────────┤
  │          │                                                  │                           │ Called 4–5× per org: current_requests_total,                  │
  │ #46 (max │ SELECT billing_periods WHERE org_id = ... AND    │ organization.rb:558       │ current_requests_total_billable, current_billing_cycle - 1,   │
  │  54/job) │ start_at <= ... ORDER BY end_at                  │ (#billing_period)         │ plus lock_cause (over_cap_lock_cause + past_due_lock_cause +  │
  │          │                                                  │                           │ legacy_past_due_lock_cause). Not memoized.                    │
  ├──────────┼──────────────────────────────────────────────────┼───────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ #5       │ SELECT COUNT(*) FROM applications WHERE active   │ intercom.rb:43, :176      │ organization.apps.count + .where(oss: false).count — fresh    │
  │          │ AND org_id                                       │                           │ COUNT per org                                                 │
  ├──────────┼──────────────────────────────────────────────────┼───────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ #80      │ SELECT users WHERE org_id                        │ intercom.rb:226,          │ owner not preloaded (used by user_admin_url_for and           │
  │          │                                                  │ organization.rb:719       │ pending_cancellation_request?)                                │
  ├──────────┼──────────────────────────────────────────────────┼───────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ #101     │ MAX(app_components.agent_last_connected_at) JOIN │ organization.rb:723       │ agent_last_connected_at — per org                             │
  │          │  applications                                    │                           │                                                               │
  ├──────────┼──────────────────────────────────────────────────┼───────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ #117     │ SELECT organizations JOIN referrals              │ intercom.rb:191           │ o.referred_by — per org                                       │
  ├──────────┼──────────────────────────────────────────────────┼───────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ #118     │ app_components                                   │ organization.rb:727/731   │ minimum_agent_version / maximum_agent_version — per org       │
  └──────────┴──────────────────────────────────────────────────┴───────────────────────────┴───────────────────────────────────────────────────────────────┘

  Suggested fixes

  1. Preload at intercom.rb:47:
     organizations = user.apps
       .includes(organization: [:owner, :subscription,
                                :referral, :app_components])
       .map(&:organization).compact.uniq | [organization].compact

     That knocks out #80, #101, #117, #118 and the
     organization.owner hits.

  2. Memoize billing_period per now (or at minimum cache
     current_billing_period). Today each of these re-queries:
     - current_requests_total → current_usage_records → billing_period
     - current_requests_total_billable → same
     - current_billing_cycle(now) / current_billing_cycle - 1
     - lock_cause sub-branches

     A simple @billing_period_cache ||= {} keyed by now.to_i on
     Organization would eliminate #46.

  3. Replace .count with .size after eager-loading :apps, or add
     a counter cache. apps.count and apps.where(oss: false).count
     always round-trip.

  Link:
  https://www.skylight.io/app/applications/exampleAppId/1776692040/24h/endpoints/IntercomSyncUserWorker?responseType=default

  Want me to draft the fix on a branch, or look at another worker?
```

## Tools

The server exposes the following MCP tools to your AI client. Tool schemas (arguments, return shapes) are discoverable via the MCP protocol itself — most clients expose them in a tool browser.

### Endpoint and trace tools

- **`list_endpoints`** — list endpoints for the selected component with latency percentiles and request-volume metrics. Filter by time window.
- **`get_endpoint_detail`** — pull an aggregate trace for a single endpoint. Returns a condensed depth-2 summary with promoted issues (N+1s, slow queries). Subsequent calls with `node_id` drill into the cached tree without a round-trip to Skylight.
- **`get_trace_node_detail`** — expand a specific node within the cached trace tree from `get_endpoint_detail`. Returns the node's subtree with category grouping and issue promotion applied.
- **`get_latency_trends`** — time-series latency trends for an endpoint over a configurable window.

### Deploy tools

- **`list_deploys`** — recent deploys for the selected app. Useful for correlating regressions with releases.

### App and component selection

- **`list_components`** — list components available on the selected app.
- **`select_component`** — scope subsequent tool calls to a specific component.
- **`select_app`** — switch which Skylight app the token-scoped session is working against (multi-app tokens only).

## Feedback

MCP integration is in Beta and actively evolving. We especially want to hear:

- **Workflows that worked.** Which prompts produced useful answers? Which didn't? Either is helpful.
- **Tool shape problems.** Arguments that felt awkward, output formats that confused your assistant, missing filters you wanted.
- **Harnesses beyond Claude Code.** We test Claude Code most heavily; let us know how Cursor / Zed / Codex / Claude Desktop behave for you.

Email us at [support@skylight.io](mailto:support@skylight.io).
