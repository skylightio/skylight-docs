---
title: Getting More from Skylight
description: Learn how Skylight works. Enable instrumentation for additional libraries and add custom instrumentation to your own code.
---

## Available Instrumentation Options

### Rails

_See the <%= link_to "Rails setup instructions", "./advanced-setup#rails-configuration" %>._

In Rails applications, we use ActiveSupport::Notifications to track the following.

* Controller Actions
* Controller File Sending
* View Collection Rendering
* View Partial Rendering
* View Template Rendering
* View Layout Rendering
* ActiveRecord SQL Queries
* ActiveRecord Instantiation
* ActiveSupport Cache
* ActiveStorage


### Grape

_See the <%= link_to "Grape setup instructions", "./advanced-setup#grape-1" %>._

* Endpoint Execution
* Endpoint Filters
* Endpoint Rendering


### Sinatra

_See the <%= link_to "Sinatra setup instructions", "./advanced-setup#sinatra-configuration" %>._

* Endpoint Execution


### Background Jobs

_See the <%= link_to "Background jobs setup instructions", "./background-jobs" %>_


### Active Job Enqueueing

_Enabled by default_

* Enqueuing of Active Jobs


### ActiveModel::Serializers

_Add_ `active_model_serializers` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* Serialization


### Coach

_Enabled by default_

* Middleware


### Couch Potato

_Add_ `couch_potato` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* Database Queries


### Elasticsearch

_Add_ `elasticsearch` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* Search Queries


### Excon

_Add_ `excon` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* HTTP Requests


### Faraday

_Add_ `faraday` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* HTTP Requests


### Graphiti

_Enabled by default for Graphiti 1.2+_

* Resource Resolving
* Resource Rendering


### GraphQL {#graphql}

_Add_ `graphql` _to <%= link_to "probes list", "./advanced-setup#probes" %>_

* Available in Skylight version 4.2.0 and graphql-ruby versions >= 1.7.
* Traces invocations of `GraphQL::Schema#execute` and `GraphQL::Schema#multiplex`

The GraphQL probe conditionally adds the `GraphQL::Tracing::NotificationsTracing` module to your schema the first time a query is executed (You may see a note about this in STDOUT).

<%= render layout: "note", locals: { type: "important" } do %>
  If you have added `use(GraphQL::Tracing::SkylightTracing)` to your schema, please remove it before adding the official Skylight probe.
<% end %>

#### Using Named Queries

In order for Skylight's trace aggregation to work properly, we highly encourage the use of **named queries**.

Skylight names your endpoint based on all the queries sent in a single request. This means that all similar queries should be grouped together. Additionally, if you send two named queries together (a multiplexed query), your endpoint name will be a combination of those two query names. You can learn more about how this works in our <%= link_to "blog post", "https://blog.skylight.io/announcing-skylight-for-graphql/" %>.

Anonymous queries will also be tracked, but instrumentation will be disabled below the `Schema#execute` span, as we don't believe aggregating divergent anonymous queries will provide you with actionable insights.

<%= render layout: "note", locals: { type: "important" } do %>
  About those query names: remember that Skylight works best when aggregating trace data. In order to keep your dynamically-named GraphQL queries appropriately grouped, it's important to limit the set of all possible names (we think 100 or so is a reasonable number).
<% end %>

### HTTPClient

_Add_ `httpclient` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* HTTP Requests


### Middleware

_Enabled by default_

* Tracks Rack Middleware in Rails applications.


### Mongo (Official Driver)

_Add_ `mongo` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* Database Queries


### Mongoid

_Add_ `mongoid` _to <%= link_to "probes list", "./advanced-setup#probes" %>._


### Net::HTTP

_Enabled by default_

* HTTP Requests


### Redis

_Add_ `redis` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* All Commands

<%= render layout: "note" do %>
  We do not instrument AUTH as it would include sensitive data.
<% end %>


### Sequel

_Enabled automatically with Sinatra or Add_ `sequel` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* SQL Queries


### Tilt

_Enabled automatically with Sinatra or Add_ `tilt` _to <%= link_to "probes list", "./advanced-setup#probes" %>._

* Template Rendering


## Custom App Instrumentation

The easiest way to add custom instrumentation to your application is by specifying <%= link_to "methods to instrument", "#method-instrumentation" %>, but it is also possible to instrument <%= link_to "specific blocks of code", "#block-instrumentation" %>. This way, you can see where particular methods or blocks of code are called in the <%= link_to "Event Sequence", "./skylight-guides#event-sequence" %>. Check out <%= link_to "an example of custom instrumentation in action", "#custom-instrumentation-in-action" %>. Be sure to follow our <%= link_to "custom instrumentation best practices", "#custom-instrumentation-best-practices" %> in order to avoid causing errors in your Skylight trace.

### Method instrumentation

Instrumenting a specific method will cause an event to be created every time that method is called. The event will be inserted at the appropriate place in the <%= link_to "Event Sequence", "./skylight-guides#event-sequence" %>. You can see an example of how this looks <%= link_to "below", "#custom-instrumentation-in-action" %>.

To instrument a method, the first thing to do is include `Skylight::Helpers` into the class that you will be instrumenting. Then, annotate each method that you wish to instrument with `instrument_method`.

~~~ ruby
class MyClass
  include Skylight::Helpers

  instrument_method
  def my_method
    do_expensive_stuff
  end
end
~~~

You may also declare the methods to instrument at any time by passing the name of the method as the first argument to `instrument_method`.

~~~ ruby
class MyClass
  include Skylight::Helpers

  def my_method
    do_expensive_stuff
  end

  instrument_method :my_method
end
~~~

By default, the event will be titled using the name of the class and the method. The event name in our previous example would be: `MyClass#my_method`. Alternatively, you can <%= link_to "customize the title", "#use-static-string-literals-for-custom-titles" %> by using the **:title** option.

~~~ ruby
class MyClass
  include Skylight::Helpers

  instrument_method title: 'Expensive work'
  def my_method
    do_expensive_stuff
  end
end
~~~


### Block instrumentation

Method instrumentation is preferred, but if more fine-grained instrumentation is required, you may use the block instrumenter.

~~~ ruby
class MyClass
  def my_method
    Skylight.instrument title: "Doin' stuff" do
      step_one
      step_two
    end
    step_three
  end
end
~~~

Just like above, the <%= link_to "title of the event can be configured", "#use-static-string-literals-for-custom-titles" %> with the **:title** option. If you don't add a title, the default for block instrumentation is `app.block`. We recommend creating your own titles to differentiate the various instrumented code blocks from one another in the Skylight UI. If you don't, they will be aggregated together, which won't be helpful for you.


### Custom Instrumentation Best Practices

#### Use Static String Literals for Custom Titles

<%= render layout: 'note', locals: { type: 'important' } do %>
  The title of an event must be the same for all requests that hit the code path. Skylight aggregates <%= link_to 'Event Sequences', './skylight-guides#event-sequence' %> using the title. You should pass a string literal and avoid any interpolation. Otherwise, there will be an explosion of nodes that show up in your aggregate Event Sequence.
<% end %>

#### Use Method Instrumentation Wherever Possible

While <%= link_to "block instrumentation", "#block-instrumentation" %> can be very useful for zeroing in on problematic minutiae, it can lead to overly complex request traces. Prefer <%= link_to "method instrumentation", "#method-instrumentation" %> where possible.

#### Avoid Over-Instrumenting Your Action

Add custom instrumentation only where necessary to understand an issue in order to avoid overwhelming yourself with too much information. Additionally, avoid instrumenting a method or block that happens a ton of times in repetition (e.g. a method called within a loop). Doing so may cause your event to exceed the size limit for an event trace in the Skylight agent.

### Custom instrumentation in action

When we first implemented <%= link_to "GitHub sign-in and sign-up", "http://blog.skylight.io/oauth-is-easy-right/" %>, we noticed the act of signing in or signing up with GitHub was pretty slow. We wanted to see which methods in our GitHub integration were taking the longest, so we added a bit of <%= link_to "method instrumentation", "#method-instrumentation" %>. The <%= link_to "Event Sequence", "./skylight-guides#event-sequence" %> for the endpoint that included those methods then looked more like this:

<%= image_tag "skylight/docs/getting-more-from-skylight/custom-instrumentation.png" %>

Clearly the `OctokitService#repo_summaries` method was the culprit of the slowdown, so we knew where more refactoring was needed and that we might even consider creating a worker to take over much of this process (just look at how long those GitHub API requests are!). Custom instrumentation to the rescue!

## Muting Skylight instrumentation {#mute}

While we do our best to collect actionable data, we can occasionally instrument too much, which may result in a trace exceeding its predefined limits. For example, if you've seen the <%= link_to "E0003 error", "./troubleshooting#exceeded-maximum-number-of-spans" %>, it may be due to over-instrumentation. In some cases, you may want to dig deeper than these limits allow, so we've introduced `Skylight.mute`. You might use this if:

 - You have too much data (as described above), and would like to dig deeper than our data limits allow
 - There is a particularly volatile section of code that does not aggregate well (for example, a webhook endpoint that completely changes behavior based on request paramters)
 - You have a sensitive area of the application that should not be instrumented due to legal or other non-technical reasons.

`Skylight.mute` is available in version 4.2.0 and higher.

#### Ignoring blocks of code

~~~ ruby
Skylight.mute do
  Skylight.instrument(title: "I-wont-be-traced") do
    ...
  end
end
~~~

#### Ignoring portions of a request

Since `mute` is block-based, we've also added an `unmute`, which counteracts the effects within a `mute` block. If you would like to skip instrumentation for a portion of your request in favor of instrumenting a later method call, you may nest `unmute` inside the `mute` block:

~~~ ruby
def show
  Skylight.mute do
    some_expensive_method
    another_expensive_method
  end
end

def some_expensive_method
  # will _not_ be traced
  ...
end

def another_expensive_method
  Skylight.unmute do
    # code inside here _will_ be traced
    ...
  end
end
~~~

## How Skylight Works

If you're curious about how our instrumentation works, you're in the right place.

###  Featherweight Agent

The Skylight agent is written primarily in <%= link_to "Rust", "https://www.rust-lang.org/" %>, a systems programming language on par with C. This means we have a very low overhead so it’s safe to run Skylight in production, even in memory limited environments like Heroku. You can read more about this aspect of our agent in our <%= link_to "Featherweight Agent blog post", "http://blog.skylight.io/our-new-featherweight-agent/" %> and more about the agent's 1.0 release in our <%= link_to "announcment post", "http://blog.skylight.io/skylight-gem-goes-1-0/" %>.


### Normalizers

Our preferred method of instrumentation is <%= link_to "`ActiveSupport::Notifications`", "http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html" %> events. When a library has added instrumentation, all we need to do is subscribe to the event and do a little bit of normalization of the data.

To standardize this process, we introduced `Normalizers`. Each type of instrumentation has its own normalizer which handles the, well, normalization. You can take a look at some of them <%= link_to "in the source", "https://github.com/skylightio/skylight-ruby/tree/v2.0.0/skylight-core/lib/skylight/core/normalizers" %>.


### Probes

While we think most libraries should include `ActiveSupport::Notifications` (anyone can subscribe to these notifications, not just Skylight), unfortunately, many still don't. In these circumstances, we have to carefully monkey-patch the libraries at their key points.

To make sure we do this in a sane fashion, we developed `Probes`. Probes are small classes that keep an eye out for specific modules and then hook into them when they're loaded. All probes can be disabled in the event of any conflicts and we only autoload probes that we have a high degree of confidence in. You can take a look at some probes <%= link_to "in the source", "https://github.com/skylightio/skylight-ruby/tree/v2.0.0/skylight-core/lib/skylight/core/probes" %>.

And, since we don't really like having to monkey-patch things either, when at all possible, we <%= link_to "submit pull requests", "https://github.com/ruby-grape/grape/pull/1086" %> to relevant projects to add in `ActiveSupport::Notifications`.

For more information about how to add an existing probe (such as Mongo, Excon, etc.) to your Skylight setup, see the <%= link_to "Advanced Setup Probes", "./advanced-setup#probes" %> page.
