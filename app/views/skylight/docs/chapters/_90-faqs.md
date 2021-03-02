---
title: FAQs
description: You guessed it — frequently asked questions!
---

## General Questions

### Is Skylight compatible with other profilers and monitoring tools?

Skylight plays nice with other profilers and monitoring solutions, including New Relic. Many of our customers run multiple tools with success! Go ahead and compare :)

### How long is your data retention period?

Our data retention period is 45 days. However, we do retain a limited set of your app's historical data with the <%= link_to "Trends feature", "./skylight-guides#trends" %>. You can view your app's trends data on your app's dashboard, or by subscribing to the Trends emails from your <%= link_to "account settings", "/app/settings/account/email_preferences" %> page.

## Reading Skylight

### What is the "Rack" endpoint?

Skylight measures the time spent in Rails actions, and most of the time, your requests end up making their way into Rails actions eventually. Once a request makes its way to an endpoint, Skylight tags the request with the endpoint's name. However, it is possible for Rack middleware to intercept the request and return a response without delegating to an endpoint. When this happens, Skylight uses the generic "Rack" name for the request, and in practice, these requests tend to be very fast. Upgrading to agent version 1.4+ will split these out by the name of the middleware that handled the request.

There are a number of different reasons why you might see "Rack" listed in your <%= link_to "Endpoints List", "./skylight-guides#endpoints-list" %>. For example, `Rack::Cache` may be intercepting your request when your app gets a cache hit. Another example is `ActionDispatch::Static`, which is an interesting case. This middleware handles requests in the /public folder and acts as an endpoint for static files. While it is not a Rails action, it does behave quite similar to a Rails action: it uniquely handles a particular URL and returns a result.

### What is the "rack.request" event?

In Rails apps, "rack.request" will usually be the first item listed in the <%= link_to "Event Sequence", "./skylight-guides#event-sequence" %>. This event represents the time spent before the actual Rails controller action is hit. Usually this event has minimal self-time.


## Security

Skylight follows generally acceptable security practices. Most importantly, we don't store any sensitive data ourselves.

### What data does my app send to Skylight?

When you install the Skylight agent in your app, it will send the following information to our servers:
* Endpoint names (without parameter values), e.g, what’s in `rake routes`
* Generic descriptions of different items in your call stack
* Sanitized SQL queries (see below)
* Response times
* Generic metadata about your application such as OS and framework version.

### Will my users' private data be sent to Skylight?

Nope. All performance metrics are scrubbed of private data by the agent running on your server before anything is ever sent our way. Skylight doesn't collect sensitive data like request param or database query values.

In fact, scrubbing parameters and values from the data your app sends is what allows Skylight to aggregate your data, providing you with an accurate view of your app’s performance on the whole.

For example, Skylight will remove variables from your SQL queries and display aggregated queries in the UI along with average durations and allocations:

<%= image_tag 'skylight/docs/faqs/sanitized-sql-query.png', alt: 'Screenshot of a sanitized SQL query' %>

### Can I read your privacy policy?

Sure! You can find it over on <%= link_to "Privacy Policy page", "/privacy" %>.

## GitHub Integration

### Why do you need read and write access to all my repos?

If you signed up for Skylight using GitHub, you may have seen this before:

<%= image_tag 'skylight/docs/faqs/github-permissions.png', style: img_width(500) %>

We don't really need write access to your repos, nor do we use it. We just want to check all the repos you have access to (public and private) to see if there are any apps on Skylight that are attached to those repos so we can give you automatic access.

Unfortunately, <%= link_to "GitHub OAuth", "https://developer.github.com/v3/oauth/" %> does not offer read-only access to public and private user repos (you can see the scopes they offer in the <%= link_to 'GitHub documentation', 'https://developer.github.com/v3/oauth/#scopes' %>, so we have to ask for read/write access even though we're really just reading.

### What about organizations?

We also request read-only access to your organizations. This is so you can choose a repo belonging to a specific organization in order to attach it to your Skylight app. There is more information about this in the <%= link_to "Add Multiple Users Through GitHub", "./app-and-account-management#add-multiple-users-through-github" %> section.

### What if I add or remove someone from a repo that's connected to Skylight?

If someone is added to a repo, they should have access to the app on Skylight as soon as they log in with GitHub.

We run a daily check to make sure everyone's access is exactly as it should be. If someone's repo access is removed, their Skylight access will be revoked when we run that check.

### I'm having a different issue involving the GitHub integration.

Check out the <%= link_to "GitHub section", "./troubleshooting#github-integration-issues" %> of our Troubleshooting page. If you don't see your issue there, feel free to email us at [support@skylight.io](mailto:support@skylight.io) and we'll help you out!

## Feature Requests

### How do I get access to beta features?

#### Accessing User Interface Beta Features

The easiest way to gain access to Skylight's UI beta features is to become a Skylight Insider. It's super easy. Just head to the <%= link_to "Labs page", "/app/settings/labs" %> and click "SUBSCRIBE" to cement your status. Once you've become an Insider, you can toggle beta feature flags on and off to your heart's content.

<%= render partial: "autoplaying_video", locals: { path_and_filename: 'faqs/feature-flag-toggle.mp4'} %>

See <%= link_to "Feature Toggles", "http://blog.skylight.io/feature-toggles/" %> for more information.

#### Accessing Agent Beta Features

Message [support@skylight.io](mailto:support@skylight.io) or contact us via the in-app messenger to see if your app is a good candidate for helping us test new agents and new agent features.

### Can I get alerts when my performance changes?

While we don't yet give you up to the minute alerts, you can get insight into your app's weekly changes by signing up for <%= link_to "Trends emails", "./skylight-guides#trends" %> in your <%= link_to "account settings", "/app/settings/account/email_preferences" %>, or by viewing your historical trends data from your dashboard. Down the road, we may add more immediate alerting when significant slowdowns occur in your app.


### Can I instrument background jobs like Sidekiq?

Although Skylight was originally designed to profile web requests, background jobs are an important aspect of performance. We use Sidekiq ourselves, and often find ourselves wanting more insight into our background jobs performance. To that end, we recently launched a Skylight for Background Jobs <%= link_to "beta program", "./background-jobs" %> to help you discover and correct hidden performance issues in your Sidekiq, DelayedJob, and ActiveJob queues. This program is available to all Skylight Insiders.

### Do you plan to add error tracking?

Right now we've chosen to focus on providing you the most useful performance information we can. That said, in the future we'd love to provide some basic notifications, especially around increased error rates. For more robust error tracking, we recommend a dedicated tool like Bugsnag.


### Can I view more than one day's worth of data at a time?

Yes, you can, via the <%= link_to "Trends feature", "./skylight-guides#trends" %>, which is available after your first two weeks of Skylight. The Trends feature shows you the last six weeks of your application's performance. You can sign up to receive your Trends reports via email, as well as view your historical trends data on your app's dashboard.

Showing weeks and months of data on demand is not as simple as it might seem. We use a technique that many time-series databases use called pre-aggregation. This means that we store all your data collated into timeslices. Timeslices make it possible to fetch arbitrarily large time ranges or time ranges that are not simply aligned to the day or hour.

At this stage, we haven't been pre-aggregating data past one hour sizes. This means that if we were to query for a two month period, we'd need to make 24 x 60 queries to fetch the data. This can quickly escalate to 100s of 1000s of queries for a single application.


### Can I cap the number of requests that I send to Skylight?

Alas, there's no way to set a limit or cap right now. This was possible in the very first version of Skylight, and contrary to our expectations, more people disliked it than found it helpful.

It turned out most of our users were already accustomed to usage-based services since they were already using them for things like hosting (Heroku, AWS, etc) and other parts of the stack. When we had the ability to set a limit, people would set it aggressively low in an effort to be frugal and then get annoyed by the notifications when they consistently hit those unrealistic thresholds. While we're sure some people would still appreciate it, overall it made significantly more people unhappy than happy, so we didn't build it into our next version.

It's also worth mentioning that Skylight is most accurate when reviewing <%= link_to "aggregated requests", "./getting-started#aggregation-vs-sampling" %> over a longer period of time, so by capping your requests and not giving Skylight all the information available, you may end up on some wild goose chases.


### Do you have this feature that New Relic has?

New Relic has lots of features we don't have but, in our opinion, they're not all that useful. We've decided to focus on making sure that everything we show you provides immediate value. Our customers find that it's easier to make sense of our UI and to get _actionable_ information from it. Sure, we could throw more stats in, but sometimes less is more.


## I've got a different question.

We would love to hear your questions. Just shoot us an email at [support@skylight.io](mailto:support@skylight.io) or use the in-app messenger ("?" in the bottom right of the web UI). See our section on <%= link_to "Submitting Feedback", "./contributing#reporting-bugs-and-submitting-feedback" %> for more details.
