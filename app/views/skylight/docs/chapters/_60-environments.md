---
title: Environments
description: Setting up and managing multiple environments.
---

## Skylight Environments

By default, the Skylight agent only enables itself in the `production` environment. In many cases, your applications will have other environments that you would like to profile using Skylight. For example, Rails ships with `development` and `test` environments by default. (You can also <%= link_to "create additional Rails environments", "http://guides.rubyonrails.org/configuring.html#creating-rails-environments" %>, such as `staging.`) This page shows you how to configure Skylight to profile these other environments so that you can view them separately in the Skylight UI:

<%= image_tag "skylight/docs/environments/environments-dropdown.png", alt: "Screenshot of Environments Dropdown", style: img_width(350) %>

### Skylight Environments vs. Rails Environments

Your Skylight environment name can differ from your Rails environment. For example, many `staging` servers are actually running the `production` environment. Or, you might have multiple staging servers running different versions of your app, so you want to see the Skylight data for them separately: `staging-1`, `staging-2`, etc. Because Skylight relies heavily on <%= link_to "request aggregation", "./skylight-guides#request-aggregation" %>, we recommend that all servers running the same version of your app be given the same environment name.

### Prioritizing the "Production" Environment

We have designed the Skylight user experience to prioritize the `production` environment. In addition to being enabled by default, the `production` environment will always be listed first in the Skylight user interface. Furthermore, only the `production` environment will be displayed in your weekly <%= link_to "Trends emails", "./skylight-guides#trends" %> (though you can still view Trends for all environments using the Trends in the UI beta feature).

For this reason, we strongly recommend against naming your primary production environment something other than `production`.

### Migrating Your Existing Environment Setup

<%= render layout: "note", locals: { type: "important" } do %>
  If you already have multiple environments set up using the legacy method of creating separate apps, the instructions on this page do not apply to you. Instead, visit <%= link_to "the merge settings page", "/app/settings/merging" %> for details on how to merge these legacy environment apps into their parent apps.
<% end %>

## Enabling Additional Environments

The process for enabling additional environments is straightforward but varies depending on how you configure Skylight and whether or not you use Rails. Be sure you are following the correct set of instructions below.

### For Rails, Using skylight.yml

#### 1. Upgrade to the latest Skylight agent.

<%= render partial: "environments_version_disclaimer" %>

#### 2. Add the new environment to Skylight's environments list.

```ruby
# config/application.rb
config.skylight.environments << "staging"
```

The environment name you add to the array should match `Rails.env` on your server. Note that if `Rails.env == "production"` you can skip this step.

<%= render layout: 'note', locals: { type: 'important' } do %>
  If you choose to do `config.skylight.environments += ["development", "staging"]` make sure to use `+=` and not `=` to add your environments, lest you accidentally turn off Skylight in your production environment.
<% end %>

#### 3. [OPTIONAL] Specify an environment name.

If your environment name is always the same as your Rails environment, the Skylight agent will automatically detect your environment! Skip this step.

**If your environment name _differs_ from your Rails environment:**

<%= link_to "See an example of why this might be the case.", "#skylight-environments-vs-rails-environments" %>

Use <%= link_to "environment-specific configuration", "#environment-specific-configuration" %> to override the environment name.

```yaml
# config/skylight.yml
authentication: <app auth token>
staging:                                 # Rails environment
  env: <%%= "staging-#{server_number}" %> # Skylight environment
```

<!-- TODO: [jobs] switch this partial to dynamic_component_names_warning -->
<%= render partial: "dynamic_environment_names_warning" %>

#### 4. Deploy and watch your data trickle in!

Deploy the above changes following your normal deploy process. Your new environment should show up in the environments selector in the Skylight UI nav bar.

### For Rails, Using Environment Variables

Alternatively, if you use environment variables to configure Skylight, follow these instructions:

#### 1. Deploy your app with the latest Skylight agent.

<%= render partial: "environments_version_disclaimer" %>

#### 2. Enable Skylight in the new environment.

Set the following environment variables in the new environment to enable Skylight.

```shell
SKYLIGHT_AUTHENTICATION=<app auth token>
SKYLIGHT_ENABLED=true
```

#### 3. [OPTIONAL] Specify an environment name.

<%= render layout: "note" do %>
  If your environment name is always the same as your Rails environment, the Skylight agent will automatically detect your environment! Skip this step.
<% end %>

**If your environment name _differs_ from your Rails environment:**

<%= link_to "See an example of why this might be the case.", "#skylight-environments-vs-rails-environments" %>

Set the environment name explicitly. For example:

```shell
SKYLIGHT_ENV=staging-42
```


### For Sinatra or Grape, using skylight.yml

#### 1. Upgrade to the latest Skylight agent.

<%= render partial: "environments_version_disclaimer" %>

#### 2. Require and start the Skylight agent in each of your desired environments.

For example, in Sinatra:

```ruby
configure :production, :staging do
  require "skylight/sinatra"
  Skylight.start!(file: PATH_TO_CONFIG, env: ENVIRONMENT)
end
```

`PATH_TO_CONFIG` should point to your `config/skylight.yml` file and `ENVIRONMENT` should return the current environment as a string (e.g. `Rails.env.to_s`).

#### 3. Specify an environment name.

Use <%= link_to "environment-specific configuration", "#environment-specific-configuration" %> to override the environment name. The environment name can be dynamic if your environment name "differs from the environment specified in `Skylight.start!`. <%= link_to "(See an example of why this might be the case.)", "#skylight-environments-vs-rails-environments" %> For example:

```yaml
# config/skylight.yml
authentication: <app auth token>
staging:
  env: "staging" # or <%%= "staging-#{server_number}" %>
```

<!-- TODO: [jobs] switch this partial to dynamic_component_names_warning -->
<%= render partial: "dynamic_environment_names_warning" %>

#### 4. Deploy and watch your data trickle in!

Deploy the above changes following your normal deploy process. Your new environment should show up in the environments selector in the Skylight UI nav bar.

### For Sinatra or Grape, Using Environment Variables

#### 1. Upgrade to the latest Skylight agent.

<%= render partial: "environments_version_disclaimer" %>

#### 2. Require and start the Skylight agent in each of your desired environments.

For example, in Sinatra:

```ruby
configure :production, :staging do
  require "skylight/sinatra"
  Skylight.start!(env: ENVIRONMENT)
end
```

`ENVIRONMENT` should return the current environment as a string (e.g. `Rails.env.to_s`).

#### 3. Enable Skylight in the new environment.

Set the following environment variables in the new environment to enable Skylight.

```shell
SKYLIGHT_AUTHENTICATION=<app auth token>
SKYLIGHT_ENABLED=true
```

#### 4. Specify an environment name in the new environment.

```shell
SKYLIGHT_ENV=staging
```

Your environment name can be <%= link_to "more specific", "#skylight-environments-vs-rails-environments" %> for finer-grained control over your Skylight data:

```shell
SKYLIGHT_ENV=staging-42
```

#### 4. Deploy and watch your data trickle in!

Deploy the above changes following your normal deploy process. Your new environment should show up in the environments selector in the Skylight UI nav bar.

## Environment-Specific Configuration

If you have Skylight enabled in multiple environments, you may want to configure each environment differently.

Environment-specific <%= link_to "configuration", "./advanced-setup#agent-configuration" %> can be set easily in `config/skylight.yml`. You can set _default configuration_ that will apply to all environments or _namespaced configuration_ to apply to a specific environment. Any variable scoped to an environment's namespace will override a default.

```yaml
# config/skylight.yml

# default configuration used in all environments goes here
authentication: <app auth token>
log_file: log/skylight.log

# namespaced configuration used only in the staging environment
staging:
  log_file: twig/skylight.log # overrides log/skylight.log
```

Alternatively, just set the appropriate ENV variables in each environment.

## Skylight Environments for Open Source Apps {#oss}

By default, the Skylight agent only enables itself in the `production` environment, but enabling Skylight in other environments is super easy!

We welcome our <%= link_to "Skylight for Open Source", "/oss" %> customers and their contributors to profile these other environments so that you can view them separately in the Skylight UI:

<%= image_tag "skylight/docs/environments/environments-dropdown-oss.png", alt: "Screenshot of Environments Dropdown for an OSS app", style: img_width(350) %>

If you would like to help an open source app enable Skylight in a new environment, see the <%= link_to "Skylight Environments", "#skylight-environments" %> section to learn more, then open a PR to the open source project.

Learn more about the Skylight for Open Source program at the <%= link_to "OSS page", "./skylight-for-open-source" %>.
