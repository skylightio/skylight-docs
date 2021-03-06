---
title: Troubleshooting
description: Having trouble with the agent? Take a look here.
---

Before proceeding, make sure that you are running the <%= link_to "latest version", "#gem-version" %> of the Skylight agent.

If you’re still having trouble after following this guide, please <%= link_to "drop us a line", "./contributing#reporting-bugs-and-submitting-feedback" %>.

## Skylight Doctor

Run `bundle exec skylight doctor` in your production terminal to check for common issues with the Skylight agent. You should see something like this as the output:

```shell
Checking SSL
  OK

Checking for Rails
  Rails application detected

Checking for native agent
  Native agent installed

Checking for valid configuration
  Configuration is valid

Checking Skylight startup
  Successfully started
  Waiting for daemon...   Success
```

<%= render layout: 'note', locals: { type: 'pro_tip' } do %>
  On Heroku you can access your production terminal with `heroku run bash`.
<% end %>

Common issues reported by `skylight doctor` include:

### Configuration is invalid

#### Authentication token required / Could not load config file

The <%= link_to "`skylight setup`", "./getting-started" %> command automatically generates a valid <%= link_to "`config/skylight.yml`", "advanced-setup#agent-configuration" %> file.

If you have edited this file, check that you haven't introduced any syntax errors or invalid configuration.

If you have removed this file, you will need to set the equivalent <%= link_to "environment variables", "advanced-setup#setting-configuration-variables" %> in any environments where you are running Skylight.

See also our documentation on <%= link_to "setting your authentication token", "advanced-setup#setting-authentication-tokens" %>.

If you are still having trouble, please run `Skylight.instrumenter.config` in your production terminal, and <%= link_to "contact us", "./contributing#reporting-bugs-and-submitting-feedback" %> with the results.

#### Sockfile path is not writeable / is an NFS mount and will not allow sockets

By default, Skylight uses your Rails `tmp` path as the sockfile directory. This directory must be writeable and cannot be located on an NFS mount (e.g. Vagrant).

Set `SKYLIGHT_SOCKDIR_PATH` (in your env) or `daemon.sockdir_path` (in your <%= link_to "config", "./advanced-setup#daemon-socket-path" %>) to a writeable, non-NFS path, like `/tmp`.

#### Logfile path is not writeable

By default, Skylight writes logs to `log/skylight.log`. In the event that this path is not writeable, set `log_file` in your <%= link_to "config", "./advanced-setup#log-file" %> to a writeable path.

### Other Issues

#### bundler: command not found: skylight

Verify that the Skylight gem is <%= link_to "in the right group", "#is-the-skylight-gem-in-the-right-group" %> and that you have run `bundle install`.

#### No Rails application detected

If you're using Sinatra or Grape, make sure you followed the installation instructions

* <%= link_to "Sinatra Instructions", "./advanced-setup#sinatra-configuration" %>
* <%= link_to "Grape Instructions", "./advanced-setup#grape-configuration" %>

#### Unable to load native extension

Check the Skylight agent <%= link_to "server requirements", "./advanced-setup#server-requirements" %> to make sure your platform is supported.

To avoid taking your production application down due to an installation failure, Skylight does not raise an exception when it can’t install the native agent. If you’re running a compatible OS and still see this warning, it’s possible that when the gem was installed, the native extension libraries failed to download from S3. If this is the case, re-installing the gem with `bundle pristine skylight` may fix the issue.

If you still see errors after re-installing, try running your application with `SKYLIGHT_REQUIRED=true`. This will cause Skylight to raise an exception when the native agent is missing. This exception may be useful in troubleshooting the problem. If you need help, send the exception message and backtrace to us at [support@skylight.io](mailto:support@skylight.io).

#### Failed to verify SSL certificate

Looks like your SSL certificates are out of date. The `skylight doctor` command will provide further instructions. By default, we try to use your local SSL root certificates, but in the event those are out of date, you can force `skylight setup` to use Skylight's bundled root certificates by running:

```shell
SKYLIGHT_FORCE_OWN_CERTS=1 bundle exec skylight setup <setup token>
```

#### Unable to reach Skylight servers

Likely this is due a temporary network issue. Please try again.

If on subsequent retries, you are still having issues, try running the following command to verify that you can connect to our authorization server:
```shell
curl -v https://auth.skylight.io/status
```

If `curl` fails, you may need to allow access to `*.skylight.io` on port 443 (e.g. if you are behind a firewall).

Finally, check our <%= link_to "Status Page", "https://status.skylight.io/" %> for the unlikely event that we are experiencing infrastructure issues.


## No Data Reporting {#no-data}

If—after updating the agent and fixing issues identified by <%= link_to "Skylight Doctor", "#skylight-doctor" %>—your data is still not reporting, consider the following questions:

### Troubleshooting Questions

#### Do you have the latest version of the Skylight gem? {#gem-version}

Make sure you are using the latest version of the Skylight gem. In the directory for your Rails app, run this command:

```shell
bundle list | grep skylight
```

You should see something like the following output:

```shell
* skylight (version number)
* skylight-core (version number)
```

Find the latest version on <%= link_to "RubyGems", "https://rubygems.org/gems/skylight" %>.

#### Did you deploy your app since setting up Skylight?

Sometimes people forget to deploy their change. Oops! Don't worry, we won't tell anyone.

#### Has your app received any requests since deploying with Skylight?

Make sure that there is traffic to your application. If your Rails app is handling requests, you should start to see data in Skylight in just a few minutes.

#### Is Skylight enabled in your current environment?

Verify that the application is running with the correct Rails environment. By default, the agent only starts in the `production` environment, but this can be configured.

To learn how to change what environments Skylight starts in, see <%= link_to "Environments", "./environments" %>.

One surprisingly common mistake people make is disabling Skylight in their production environment:

```ruby
# config/application.rb
config.skylight.environments = ["staging"]  # DO NOT DO THIS
config.skylight.environments += ["staging"] # DO THIS
```

#### Is the `skylight` gem in the right group?

Verify that, in your app’s `Gemfile`, you’ve added the `skylight` gem to a group that will be installed in production. For example, if you add `skylight` to the `development` group, it will not run when you deploy to production.

#### If you're running Unicorn, did you restart your master?

To make sure Skylight is activated, you may need to restart your Unicorn masters.

<%= render layout: 'note', locals: { type: 'important' } do %>
  If you notice that the pre-fork (master) has not restarted on a typical deploy, make sure that you run a true restart (stop/start), rather than a reload.
<% end %>

## Data Gaps

### Agent Stops Reporting

You might see the "No data within this time range" message if the agent running in your Rails app stops reporting performance data to Skylight. If you were able to see data before but it has stopped working recently, restarting your server will usually fix the issue.

If the agent encounters multiple errors in a short span of time, it will shut itself down. This is done out of an abundance of caution to ensure that a potential bug in the agent doesn’t bring down your app in production.

We are working to add more logging to the agent so we can better diagnose what causes the agent to shutdown and recover gracefully in the event of an error. If you find this is happening regularly, please let us know!

### Missing Requests

Please check your logs for <%= link_to "Skylight errors", "#skylight-errors" %>.

### Select a Range with More Requests

<%= image_tag "skylight/docs/troubleshooting/mismatch-error.png", alt: "Screenshot of an endpoint page with a time frame selected that has 1 request but displays the message 'Please select a range with more requests in order to view a trace.'" %>

This is due to our use of two different compression algorithms for the data. In some rare cases, especially when there were only one or two requests in a range, there's a slight mismatch between the algorithms. We hope to resolve this in future iterations.

### Web Requests are Sent to the Background Jobs Component (or vice versa)

When the Skylight instrumenter starts, it attempts to determine what sort of process is running (either a web server or a background job processor). As there is no standard interface for doing so, it relies on a number of known hints. If your app uses a more bespoke setup, Skylight may send data to the wrong component. This is more likely to happen if you have set a custom worker component name, in which case it can be solved by setting `SKYLIGHT_COMPONENT=web` in the environment that runs your web server.

Similarly, if you have background job data reported to your web server, setting `SKYLIGHT_COMPONENT=worker` when running your background jobs should tell Skylight to direct these traces to your worker component.

Even if this fixes your issue, please do email [support@skylight.io](mailto:support@skylight.io) and let us know exactly what commands you use to start your server or background jobs processors&mdash; we'd like automatically handle as much of these as possible.

## Skylight Errors

The Skylight agent will log errors to `log/skylight.log` or on Heroku in STDOUT (Look for lines starting with `[SKYLIGHT]`).

### Event Errors

#### `[E0001] Spans were closed out of order` and `invalid span nesting` {#e0001}

This error indicates that a parent span (event sequence item) was closed before all of its children were.

One common cause of this issue is a Middleware that doesn't conform to the <%= link_to "Rack SPEC", "http://www.rubydoc.info/github/rack/rack/file/SPEC" %>. Specifically, "If the body is replaced by a middleware after action, the original body must be closed first, if it responds to `close`." If you are unable to fix the Middleware, you can remove the Middleware probe with `config.skylight.probes -= ['middleware']` in your Rails config (note that you will no longer see individual Middleware in your endpoints list or endpoint event sequences; all Middleware will show up as "Rack" instead).

### Too many unique span descriptions

#### `[E0002] You've exceeded the number of unique span descriptions per-request.` and `A payload description produced <too many uniques>` {#e0002}

Skylight limits the number of unique span (event sequence item) descriptions in a request to 100 to prevent misbehaving apps from causing trouble. In most cases, this will be fine as even items such as similar repeated queries will be normalized into a single description (e.g. `SELECT * FROM users WHERE id = 1` and `SELECT * FROM users WHERE id = 2` both become `SELECT * FROM users WHERE id = ?`). However, if your request is extremely complex it is possible to exceed this limit. To resolve this issue, reduce the number of uniquely named items that you instrument.

### Exceeded maximum number of spans

#### `[E0003]` Exceeded maximum number of spans {#e0003}

Skylight limits the maximum number of spans (event sequent items) in a request to 2,048 to prevent a data overload. If your request is very complex, you may hit this limit and data will no longer be tracked for that request. A couple common causes include:

1. **The request itself is very complex.** For example, requests that generate a significant number of SQL queries have been known to trigger this error. Be sure to check out our <%= link_to "Performance Tips", "./performance-tips" %> to reduce the complexity of your request.
2. **Your custom instrumentation is overly complex.** Be sure to follow our <%= link_to "custom instrumentation best practices", "./getting-more-from-skylight#custom-instrumentation-best-practices" %>.

### Failed to extract binds from SQL query {#e0004}

#### `[E0004] Failed to extract binds from SQL query.` and `Failed to lex SQL query`

These errors indicate that the agent is unable to parse a SQL query in your application. There errors won't prevent your application from operating, though they will reduce the information that we can display in the UI for these queries. They will be displayed in the <%= link_to "Event Sequence", "./skylight-guides#event-sequence" %> as simply "SQL", not the full sanitized query.

Generally, the reason you will see this error is because you're using a syntax we do not recognize (often a more complex or non-standard syntax). We've optimized for the most common syntax constructions and plan to support more in the future.

When running across this error, please <%= link_to "report it", "./contributing#reporting-bugs-and-submitting-feedback" %> so we can learn what queries are important to our customers. If this error becomes too noisy, you can disable it by setting `log_sql_parse_errors: false` in your <%= link_to "config", "advanced-setup#setting-configuration-variables" %>. Alternately, you may selectively disable Skylight for certain noisy spans using <%= link_to "Skylight.mute", "./getting-more-from-skylight#mute" %>.


### Other Errors

#### `ERROR:skylight::cli: skylightd exiting abnormally; err=DaemonLockFailed`

As per <%= link_to "this issue in the agent repo", "https://github.com/skylightio/skylight-ruby/issues/21#issuecomment-67730166" %>, the fix for this is relatively quick. Just explicitly set `daemon.sockdir_path` in your <%= link_to "config", "./advanced-setup#daemon-socket-path" %> to a writeable, non-NFS path.

## GitHub Integration Issues

### I logged in with GitHub but still don't see the GitHub-connected app(s) I'm expecting to see!

First, try <%= link_to "syncing your GitHub account with Skylight", "https://www.skylight.io/app/settings/account" %>. If that doesn't work, it's possible the GitHub organization that owns the repo needs to <%= link_to "grant permissions", "#grant-permissions" %> in order for us to see that you are a member of the repo. Ask your GitHub org's administrator to add Skylight to the approved access list, then <%= link_to "sync your GitHub account again", "https://www.skylight.io/app/settings/account" %>. You should then have access to the app(s) you expected to see!

<a name="whitelist-skylight"></a>
### I am having trouble accessing my GitHub organization in Skylight. {#grant-permissions}


If you don't see your organization in the dropdown when trying to connect an app or your users encounter issues accessing your GitHub-connected apps, you may have your GitHub organization's "Third-party application access policy" set to "Access restricted."

You can check our current permissions by visiting the "Third-party access" settings for your organization. If the permissions are correct, Skylight will be marked as "Approved":

<%= image_tag "skylight/docs/troubleshooting/third-party-access-2.png", alt: "Screenshot of the GitHub third party access page", style: img_width(400) %>

Your organization must allow third-party access to Skylight so that we can use the GitHub API to access any information about your org. Click the link below the "Connect Your GitHub Repository" dropdown on the app settings page to update your <%= link_to "GitHub permissions", "https://github.com/blog/1941-organization-approved-applications" %>. This link takes you to a page in GitHub, where you can click the "Grant" button to give Skylight access to the necessary information:

<%= image_tag "skylight/docs/troubleshooting/third-party-access.png", alt: "Screenshot of the GitHub organization access page", style: img_width(300) %>

### I'm trying to add a repo to my Skylight app but I don't see the field to do so.

There are a few reasons why this might happen.

1. You are not the owner of the app on Skylight. You may contact the owner to have them add a repo to the app, or have them transfer ownership to you (this would entail transferring billing to you as well, so you may not want to do that).
2. You are the owner, but are not logged in with GitHub. We need to verify your credentials, so be sure you are logged in via GitHub.

### I'm having problems connecting my Skylight app to a personal GitHub repo.

Sorry, right now we only support repos that are connected to an organization, though we may allow use of personal repos in the future. Shoot us an email at [support@skylight.io](mailto:support@skylight.io) to let us know if this feature is important to you!

### I followed an email invitation and signed up with GitHub. How come I don't see any apps when I log in?

This is actually a known bug, but it's quite rare these days and we've had trouble reproducing it, so have had trouble fixing it. Please do email [support@skylight.io](mailto:support@skylight.io) and let us know exactly what steps you took when signing up, especially if there were any errors or issues along the way, or if you refreshed the invitation signup page at all before clicking "sign up with GitHub." Any information about anything out of the ordinary helps!

In the meantime, you can ask the person who initially invited you to send another invitation to the email address associated with your account. This will add you to the app automatically and you should have no further issues.

## Other Issues

### I ran a memory profiler. Why are so many object allocations attributed to Skylight?

Memory profiler gems like <%= link_to "`memory_profiler`", "https://github.com/SamSaffron/memory_profiler" %> and <%= link_to "`derailed`", "https://github.com/schneems/derailed_benchmarks" %> generally use Ruby's <%= link_to "`ObjectSpace`", "https://ruby-doc.org/core-2.4.0/ObjectSpace.html" %>—a really nifty way to get information about all the objects allocated in your Ruby application that is great for troubleshooting memory issues.

Digging into the source of both `derailed` and `memory_profiler` (which is used by derailed), we discovered the following line (<%= link_to "source", "https://github.com/SamSaffron/memory_profiler/blob/6ff1bb359e5dc0ff15603cb71687f6ee6d75cfc6/lib/memory_profiler/reporter.rb#L93" %>):

```ruby
file = ObjectSpace.allocation_sourcefile(obj)
```

This line looks at an object and asks `ObjectSpace` who caused it to be allocated. As it turns out, objects allocated at require time are attributed to the file that calls the original `Kernel#require` method.

Now, this is all well and good except for one small problem: Skylight <%= link_to "overwrites", "https://github.com/skylightio/skylight-ruby/blob/2ccc1c573e7b7d17e24c0afb238f42c2e0a650a5/lib/skylight/probes.rb#L77-L91" %> `Kernel#require` in order to properly install probes. This means that it is Skylight that calls the original `Kernel#require`, not whatever other gem is _really_ doing the require. So, as soon as Skylight is loaded, every future `require` call is attributed to Skylight.

Skylight isn't the only library to do this. ActiveSupport has a <%= link_to "similar hook", "https://github.com/rails/rails/blob/v4.2.2/activesupport/lib/active_support/dependencies.rb#L272-L276" %> in it's `Loadable` module that is included into `Object`. Without Skylight, it would be ActiveSupport taking the blame. However, because this hook uses `super`, it calls to the superclass `Kernel` that is now the version that Skylight created.

Even RubyGems itself gets in on the <%= link_to "overwriting behavior", "https://github.com/rubygems/rubygems/blob/bdc8f0d60d17eb689b85cc318ea948b9581c0fdc/lib/rubygems/core_ext/kernel_require.rb#L39-L52" %>. Though, if you use Bundler (as everyone is), this is <%= link_to "actually reversed", "https://github.com/bundler/bundler/blob/bc87d05ff3565551ec3b2d32a5c08aa3cf24beb8/lib/bundler/rubygems_integration.rb#L254-L264" %>.

So there you have it, run `derailed` without Bundler and you'll see RubyGems blamed for your requires. Add in Bundler and the correct files will get blamed. Bring in ActiveSupport and then ActiveSupport will be blamed. Include Skylight and blame will shift to us. Good times!

So what's the moral here? Know your tools. `ObjectSpace` and the libraries that use it do some really useful things. They aren't perfect, but they're open source. Read the code and find out a bit about how they work and you'll be able to put them to better use!

### What if I need to load the Skylight gem before Rails?

Skylight performs setup when the gem is required, at which time Rails will be detected and tapped into. However, you may find you have to manually require `skylight/railtie` if you need to load the Skylight gem before Rails.

### I'm suddenly seeing many more requests than usual and my bill has gone way up, but my app has very few page views. What's going on? {#more-requests-than-usual}

Unfortunately, it's possible that your app has been the target of some malicious bots or abusive requests. Even if you see very few page views, that is not an accurate indicator of how many requests your app is receiving behind the scenes. An overzealous health checker is another possible source, if you are using such a service.

We strongly recommend that you look into the source of the abusive requests so they don't continue or return. Many Skylight users have reported success using something like <%= link_to  "Rack Attack", "https://github.com/kickstarter/rack-attack" %> to deal with these requests. You can also use a library like <%= link_to "IPCat", "https://github.com/kickstarter/ipcat-ruby" %> with Rack Attack to access a list of known IPs for "datacenters, co-location centers, shared and virtual webhosting providers. In other words, ip addresses that end web consumers should not be using."

If you want to avoid seeing these requests in Skylight, we recommend placing Rack::Attack at the top of your middleware stack (good practice even without Skylight) and then [running Skylight immediately afterward](./advanced-setup#middleware-stack).

If you find yourself in this position, here are some tips (from an actual Skylight customer!) on how you might deal with finding and blocking the abusive requests:

1. From the Skylight endpoints page, sort by "popularity" to see which ones have the highest amount of requests per minute (RPM)
2. Use a logging service to browse server logs (we use <%= link_to "Logentries", "https://logentries.com/" %>)
3. Filter HTTP requests for the endpoints from step 1
4. Look for unexpected behavior, such as frequent requests every minute
5. Choose a request from that group, select the remote IP, and use that as a second filter
6. This should help you confirm which IP address is making all those requests! If you're curious, you can try to look up the IP address with a search engine to find the website associated with the IP address.
