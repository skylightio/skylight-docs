---
title: Background Jobs
description: Setting up and managing instrumentation for your workers.
---

## Skylight for Background Jobs

While Skylight was originally designed to profile web requests, we understand that the web interface is only a part of your server-side application. We developed Skylight for Background Jobs in order to help you discover and correct hidden performance issues in your Sidekiq, DelayedJob, and ActiveJob queues.

By default, the Skylight agent only enables itself for web requests. In many cases, your applications might run processes in the background, via <%= link_to "Sidekiq", "https://sidekiq.org/" %>, <%= link_to "Delayed::Job", "https://github.com/collectiveidea/delayed_job" %>, or some other framework. In fact, we recommend moving certain slow actions into background jobs in our <%= link_to "Performance Tips", "./performance-tips#move-third-party-integration-to-workers" %>. This page shows you how to configure Skylight to profile your background jobs so that you can view them separately in the Skylight UI:

<%= image_tag "skylight/docs/background-jobs/background-jobs.png", alt: "Screenshot of the Background Jobs user interface", style: img_width(300) %>

### Currently Supported Libraries and Frameworks {#probes}

#### We currently have instrumentation for:

* <%= link_to "Sidekiq", "https://sidekiq.org/" %>
* <%= link_to "Delayed::Job", "https://github.com/collectiveidea/delayed_job" %>
* <%= link_to "ActiveJob", "https://guides.rubyonrails.org/active_job_basics.html" %> (supporting Sidekiq, Backburner, Que, Delayed::Job, Sneakers, Shoryuken, and others)

<%= link_to "Resque", "https://github.com/resque/resque" %> is officially **not** supported for now, due to incompatibilities between Resque and Skylight's process model (it doesn’t work via ActiveJob either).

### Limitations

* Currently, jobs running over four hours will not be tracked (we have incrementally raised this limit and are still investigating the potential effects of raising it further).
* Jobs and requests with more than 2,048 items in the event sequence will result in "pruned" traces. In the job view in the UI, you may see nodes with the description "exceeded the maximum number of events allowed by the Skylight agent," which means that some nodes were dropped from the trace before it was submitted. You can read more about this limitation in our <%= link_to "Troubleshooting docs", "./troubleshooting#e0003-exceeded-maximum-number-of-spans" %>. Typically, you would see this error for individual jobs that do a lot of repetitive work--- we generally recommend splitting these up so one job instance performs one unit of work.

### Default Jobs Component Naming {#component-names}
By default, we will detect that you are running jobs and report them as a `worker` component. If you would like to see another name in the Skylight user interface, the component name can be customized, according to the <%= link_to "instructions", "#enabling" %> for your specific configuration setup.

<%= render layout: "note", locals: { type: 'important' } do %>
  Customizing the component name only works for background job processes. Web requests will always be reported as `web`.
<% end %>

### Migrating Your Existing Background Jobs Setup

<%= render layout: "note", locals: { type: 'important' } do %>
  If you already have background jobs set up using the legacy method of creating a separate app for your workers and using a third-party gem, visit the <%= link_to "merge settings page", "/app/settings/merging" %> for details on how to merge these legacy worker apps into their parent apps to maintain data continuity.
<% end %>

<%= render layout: "note", locals: { type: 'important' } do %>
  If you have previously used the third-party `sidekiq-skylight` gem, we recommend removing it from your Gemfile. It is incompatible with Skylight 4.0. Additionally, you may need to update your <%= link_to "ignored endpoints configuration", "./advanced-setup#ignoring-heartbeathealth-check-endpoints" %> to remove the `#perform` method name from the worker name.
<% end %>

## Enabling Background Job Instrumentation {#enabling}

The process for enabling background jobs instrumentation is straightforward but varies depending on how you configure Skylight and whether or not you use Rails. Be sure you are following the correct set of instructions below.

### Using skylight.yml

#### 1. Upgrade to the latest Skylight agent.

<%= render partial: "background_jobs_version_disclaimer" %>

#### 2. Enable Skylight for your job processing framework. {#enabling-frameworks}

**If you use Sidekiq:**

```yaml
# config/skylight.yml
authentication: <app auth token>
enable_sidekiq: true
```

If you use Sidekiq with ActiveJob, you can enable either the Sidekiq config or the ActiveJob probe (read on to the next section), or both (it's not necessary to do both, but it won't hurt).

**If you use ActiveJob:**

```ruby
# config/application.rb
config.skylight.probes << 'active_job'
```

**If you use Delayed::Job:**

```ruby
# config/application.rb
config.skylight.probes << 'delayed_job'
```

#### 3. [OPTIONAL] Specify a component name.

<%= render(layout: "note") do %>
  If you would like to use the default `worker` component name, skip this step. See <%= link_to "Component Names", "#component-names" %> for more information.
<% end %>

**If you would like to use a _custom_ component name:**

Use <%= link_to "environment-specific configuration", "#environment-specific-configuration" %> to override the environment name.

```yaml
# config/skylight.yml
authentication: <app auth token>
enable_sidekiq: true # if you are using sidekiq
worker_component: 'sidekiq' # or <%%= worker_component_name %>
```

<%= render partial: "dynamic_component_names_warning" %>

#### 4. Deploy and watch your data trickle in!

Deploy the above changes following your normal deploy process. Your new worker component should show up in the components selector in the Skylight UI nav bar.

<%= image_tag "skylight/docs/background-jobs/components-dropdown.png", alt: "Screenshot of Components Dropdown", style: img_width(350) %>

### Using Environment Variables

Alternatively, if you use environment variables to configure Skylight, follow these instructions:

#### 1. Deploy your app with the latest Skylight agent.

<%= render partial: "background_jobs_version_disclaimer" %>

#### 2. Enable Skylight for your jobs.

Set the following environment variables wherever you start your jobs (e.g. in the `Procfile` on Heroku):

```shell
SKYLIGHT_AUTHENTICATION=<app auth token>
SKYLIGHT_ENABLE_SIDEKIQ=true # for sidekiq instrumentation
```

For ActiveJob and Delayed::Job, you'll need to <%= link_to "enable the appropriate probes", "#enabling-frameworks" %> in `config/application.rb` and deploy that change.

#### 3. [OPTIONAL] Specify a component name.

<%= render layout: "note" do %>
  If you would like to use the default `worker` component name, skip this step. See <%= link_to "Component Names", "#component-names" %> for more information.
<% end %>

**If you would like to use a _custom_ component name:**

Set the environment name explicitly wherever you start your jobs. For example:

```shell
SKYLIGHT_COMPONENT=sidekiq
```

## Background Jobs for Open Source Apps {#oss}

By default, the Skylight agent only enables itself for web requests, but enabling Skylight for background jobs is super easy! We welcome our <%= link_to "Skylight for Open Source", "/oss" %> customers and their contributors to profile their background jobs so that you can view them separately in the Skylight UI:

<%= image_tag "skylight/docs/background-jobs/background-jobs-oss.png", alt: "Screenshot of the Background Jobs for OSS user interface", style: img_width(600) %>

If you would like to help an open source app enable Skylight background job instrumentation, read the above documentation to learn about Background Jobs, then open a PR to the open source project.

Learn more about the Skylight for Open Source program at the <%= link_to "OSS page", "./skylight-for-open-source" %>.

## Background Job Terminology {#terminology}

Although most of the Skylight UI remains unchanged when viewing your jobs, there are a few subtle differences in terminology that you'll see in your Skylight dashboard. Below are a few helpful definitions to help you understand your jobs performance.

#### Problem duration
The 95th percentile job duration. One out of every 20 jobs processed is slower than the 95th percentile (equivalent to <%= link_to 'problem response time', "./getting-started#true-response-times" %> for web requests). {#problem-response}

#### Typical duration
The 50th percentile job duration. This number indicates the median of your processed jobs duration, which is to say that half of the jobs processed will be faster than this, while the other half will be slower (equivalent to <%= link_to 'typical response time', "./getting-started#true-response-times" %> for web requests).

#### Jobs processed
The total number of jobs that were processed in a given time period.

#### Queues
The queue in which a background job was run. This may be the default queue or a specific, named queue.

#### Frequency
The number of times this job was processed per minute. A higher frequency of a job means more jobs processed.

#### Agony
A weighted measure of how slow a job was and how frequently it was processed, ranging from 0 to 3; equivalent to our web request version of <%= link_to "endpoint agony", "./skylight-guides#agony" %>.

## Additional Information {#additional-info}

### Pricing

Billing is based on the total number of monthly traces across all of your apps. Web requests and background jobs are both considered traces, and are treated equally in terms of billing. Every account gets 100,000 free traces per month, with tiers starting at $20 per month for more. Learn more on our <%= link_to "pricing page", "/pricing" %>.

### Submitting Feedback

We welcome feedback and bug reports via the <%= link_to "in-app messenger", "./contributing#reporting-bugs-and-submitting-feedback" %> or by email at [support@skylight.io](mailto:support@skylight.io).
