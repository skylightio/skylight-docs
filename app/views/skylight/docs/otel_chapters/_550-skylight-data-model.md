---
title: Skylight Data Model
description: Mapping between Otel and Skylight's data models
---

## Skylight vs OpenTelemetry

OpenTelemetry is a general purpose instrumentation framework, it is meant to support a large variety of use cases and scenarios. As such, Otel traces has a flexible generic data model, often aiming to include as much information as possible just in case they are useful.

On the other hand, Skylight is a relatively focused tool with rather specific goals. Rather than showing you detailed views on what happened in a handful of random transactions and hoping for them to be representative or insightful, we aim to collect information across many transactions, _aggregate_ similar ones together to help you form an accurate big picture understanding, surfacing any useful trends, patterns and anomalies hidden within.

We believe it should be easy for engineers to keep an eye on performance, and when it comes time to investigate and improve on things, it should be quick to get answers and find areas to focus their efforts, without needing to be a data scientist and having to manually comb through a vast amount of data.

Concretely we want to help you effortlessly get answers to questions such as:

* Are things generally okay, performance wise?
* Which direction are we trending?
* Which are my slowest endpoints?
* Which slow endpoints are affecting the most customers?
* What is making an endpoint slow? Where does it spend its time?
* Why is an endpoint particularly slow for some customers only?

...and many more.

Due to the different focus, while OpenTelemetry traces works great as an input source into the Skylight ecosystem, there are some differences between the underlying data models.

This article explains these differences, how we attempt to automatically map concepts from the OpenTelemetry data model into Skylight's data model.

## Skylight Attributes

While the default mapping works well in many cases, there may be cases where you want more direct control. We will discuss how you can explicitly specify some of these values using special attributes.

Note that the solution discussed here assumes you are able to modify your instrumentation code to include these additional attributes. If you are able and willing to do so, this is often the easiest solution – you simply open your source code, navigate to where the instrumentation spans are produced and type away.

However, this is not always practical. Sometimes, the instrumentation spans are generated from a library which you cannot modify. Or perhaps you just do not want to put Skylight-specific concerns inside your source code. In the next chapter, we will discuss the normalizers system, which essentially allows these attributes to be inserted after the fact, without modifying instrumentation code and without affecting other consumers of the telemetry data.

## Conventions

When discussing attributes names, we will use the following conventions:

* `$resource[foo.bar]`: the attribute `"foo.bar"` set on the Otel resource.
* `$scope[foo.bar]`: the attribute `"foo.bar"` set on an Otel instrumentation scope.
* `$span[foo.bar]`: the attribute `"foo.bar"` set on an Otel span.
* `$event[foo.bar]`: the attribute `"foo.bar"` set on an Otel span event.

Most of the time, you would be working with span-level attributes.

## App

Your Skylight dashboard is organized by _apps_. A Skylight app corresponds to a single application you want to instrument. Access control and billing is also specific to each Skylight app.

Apps can be created on the Skylight UI as needed, and they are identified with an unique auth token.

<!-- TODO: screenshot -->

OpenTelemetry does not have a direct equivalent, though there are some overlap with certain resource attributes.

At the agent level, the main concern is to correctly associate trace data with an appropriate app through its auth token, which is covered in "Authentication" section in the previous chapter.

## Component

Each Skylight app can be further sub-divided into components – web, worker, etc. App components are automatically created on-the-fly in the backend as data arrives.

<%= image_tag "skylight/docs/background-jobs/components-dropdown.png", alt: "Screenshot of Components Dropdown", style: img_width(350) %>

In OpenTelemetry, the closet concept is the `$resource[service.namespace]` attribute. If this attribute is set, the trace will be added to a component with that name. Otherwise, the default component "web" will be used.

Alternatively, this can also be specified with one of these Skylight-specific attributes with priority over `$resource[service.namespace]`:

* `$resource[skylight.component]`
* `$scope[skylight.component]`
* `$span[skylight.component]`
* `$event[skylight.component]`

When multiple of these are present, the "most specific" attribute will take priority.

For example, when different values are assigned at both the `$resource` and `$scope` level, `$scope[skylight.component]` will take priority. If multiple spans specified `$span[skylight.component]`, the last span with that attribute will take priority.

## Environment

Each app component can operate under different environments – production, staging, etc. App environments are automatically created on-the-fly in the backend as data arrives.

<%= image_tag "skylight/docs/environments/environments-dropdown.png", alt: "Screenshot of Environments Dropdown", style: img_width(350) %>

In OpenTelemetry, this is specified with the `$resource[deployment.environment.name]` attribute. If this attribute is set, the trace will be added to an environment with that name. Otherwise, the default environment "production" will be used.

Alternatively, this can also be specified with one of these Skylight-specific attributes with priority over `$resource[deployment.environment.name]`:

* `$resource[skylight.environment]`
* `$scope[skylight.environment]`
* `$span[skylight.environment]`
* `$event[skylight.environment]`

When multiple of these are present, the "most specific" attribute will take priority.

For example, when different values are assigned at both the `$resource` and `$scope` level, `$scope[skylight.environment]` will take priority. If multiple spans specified `$span[skylight.environment]`, the last span with that attribute will take priority.

## Traces

At the most basic level, Skylight and OpenTelemetry shares a similar basic data model for a trace. Most of the data for a trace is found in its root span.

The main difference lies in that Skylight needs a way to aggregate _similar_ traces together and label them for display purposes in the UI.

### Trace Name

In Skylight, each trace has a name, which identifies and describes the type of the transaction represented by this trace. For web request, this can be the route name (e.g. `UsersController#show`); for background jobs, this is often the name of the job (e.g. `UserEmailWorker`).

Note that this is **required**. Traces without a name will be dropped in the agent. The Skylight backend aggregates related traces together based on their names. Appropriate trace naming ensures useful aggregation, as only traces with similar shapes (traces that takes roughly the same code paths and performs roughly the same operations) are aggregated together.

<%= image_tag 'skylight/docs/features/endpoint-view.png', alt: 'Screenshot of an aggregate trace in the Skylight UI' %>

OpenTelemetry does not have an equivalent concept here. Some routing libraries or background job frameworks are known to emit spans with attributes that would work for this purpose, and in those cases we may offer built-in normalizers to extract that automatically.

Otherwise, you can specify this with one of these Skylight-specific attributes:

* `$scope[skylight.trace.name]`
* `$span[skylight.trace.name]`
* `$event[skylight.trace.name]`

When multiple of these are present, the "most specific" attribute will take priority.

For example, when different values are assigned at both the `$scope` and `$span` level, `$span[skylight.trace.name]` will take priority. If multiple spans specified `$span[skylight.trace.name]`, the last span with that attribute will take priority.

In addition to setting this attribute to a string, you may also set this to the boolean `true` value (not the string `"true"`!). In that case, the name of the scope/span/event where this is set will be used as the trace name.

### Trace Segment

Skylight Traces with the same name can optionally be further sub-divided into _segments_. For example, this can be used to split out error responses or group together transactions where specific conditions are met.

On the backend, only traces with the same name _and_ segment will be aggregated together. By default, the segment is unset and traces are grouped only by name.

<!-- TODO: screenshot -->

Because this is a somewhat open-ended concept, there is no directly equivalent concept in OpenTelemetry.

This can be specified with one of these Skylight-specific attributes:

* `$scope[skylight.trace.segment]`
* `$span[skylight.trace.segment]`
* `$event[skylight.trace.segment]`

When multiple of these are present, the "most specific" attribute will take priority.

For example, when different values are assigned at both the `$scope` and `$span` level, `$span[skylight.trace.segment]` will take priority. If multiple spans specified `$span[skylight.trace.segment]`, the last span with that attribute will take priority.

## Span

At the most basic level, Skylight and OpenTelemetry shares a similar basic data model for spans. Every span has a start and end timestamp, which denotes the time elapsed during a certain operation. Each trace has exactly one root span, and every span can have zero or more child spans.

In Skylight, we are interested in aggregating together the same operation across many related transactions.

For example, let's consider a `UserSignUp` trace type. It may involve first making a request to an external service to verify a CAPTCHA, then running a `SELECT` database query to verify the username is available, then running an `INSERT` database query to register the user's information, finally sending a notification email.

These same operations occur in all `UserSignUp` traces, but on any single transaction, the details are a bit different. For one thing, each of those operations will take a different amount of time to complete. Further, those operations will also be performed with different parameters – checking for different usernames in the `SELECT` queries, sending the notification emails to different email addresses and with slightly different contents.

What we want to do is to preserve the fact that these four operations happen in every transaction, maintain their relative ordering and gather statistics about the duration for each operation separately. We'll discard the parameters for each operation as those are unique to each transaction and cannot be aggregated.

To facilitate this, we reduce every span down to a title, a category and a description, which the Skylight backend uses to aggregate related spans when all three fields matches.

<%= image_tag 'skylight/docs/features/child-events.png', alt: 'Screenshot showing an aggregate span in the Skylight UI' %>

### Span Title

In Skylight, span titles are short pieces of text that summarize the operations they represent. It's the primary way we label spans in UI.

In OpenTelemetry, every span has a name, which largely serves the same purpose.

By default, the Otel span name is taken as the span's title. This usually works well, but sometimes the span name may be overly verbose or contains information unique to that specific trace.

In those cases, this can be specified with one of these Skylight-specific attributes:

* `$span[skylight.title]`
* `$event[skylight.title]`

When both of these are set, `$event[skylight.title]` will take priority and be used as the title for the enclosing span. If multiple span events in the same span contains the `$event[skylight.title]` attribute, the last one will be used.

### Span Category

In Skylight, span categories are well-known strings that describes the type of the operation represented by the span. The following are supported:

* `app` – instrumentation spans emitted by the application, as opposed to those emitted by a third-party library
* `api` – an request to an external service
* `db` – general database-related operations
* `db.sql.query` – a SQL database query
* `view` – template rendering
* `other` – uncategorized

Span categories are primarily used to aid visualization in the Skylight UI. For example, `app` are colored in blue, `db` in green, and `view` in purple. The `db.sql.query` category enables SQL syntax highlighting in the popover. They also helps display contextually relevant help messages and link to support articles.

Perhaps surprisingly, there isn't a direct equivalent to this concept in OpenTelemetry spans. While the rich [semantic convention][otel-semconv] exists, it governs how different categories of metadata are encoded as span attributes, but it does not categorize the span as a whole into a single category. In theory, it is possible for a single span to have attributes across a wide range of semantic categories.

Nevertheless, most Otel spans implicitly belong to a single category only. For example, a span with the `$span[db.query.text]` attribute can be understood as belonging to the `db.sql.query` Skylight category.

The built-in normalizers will attempt to make these inferences based on some common attributes. Otherwise, the default `other` category will be used.

Alternatively, this can also be specified with one of these Skylight-specific attributes, which takes priority over the inferred category:

* `$span[skylight.category]`
* `$event[skylight.category]`

When both of these are set, `$event[skylight.category]` will take priority and be used as the title for the enclosing span. If multiple span events in the same span contains the `$event[skylight.category]` attribute, the last one will be used.

### Span Description

In Skylight, span descriptions are an optional longer free-form text field that describes the operation. Even though this is "free-form", it still cannot contain transaction-specific information in order for aggregation to work.

In the Skylight UI, the description is generally displayed in the popover when clicking on a span.

For example, in the `db.sql.query` category, the description would be the sanitized form of the SQL query, e.g. `SELECT * FROM users WHERE username = ?`. In the `api` category, the description may contain the domain name of the external service, but not the full URL as that may contain parameters that are unique to each transaction.

The built-in normalizers will attempt to extract useful information into this field based on some common Otel attributes. Otherwise, it will be left unset.

Alternatively, this can also be specified with one of these Skylight-specific attributes, which takes priority over the inferred category:

* `$span[skylight.description]`
* `$event[skylight.description]`

When both of these are set, `$event[skylight.description]` will take priority and be used as the title for the enclosing span. If multiple span events in the same span contains the `$event[skylight.description]` attribute, the last one will be used.

<!-- TODO deploys, source location -->

## Other Skylight Features

### Ignoring a Trace

You can exclude a trace from being submitted to the backend with one of these Skylight-specific attributes:

* `$scope[skylight.trace.ignore]`
* `$span[skylight.trace.ignore]`
* `$event[skylight.trace.ignore]`

If any of these are set at any level, and its value is `true` (not the string string `"true"`!), the trace will be ignored and dropped in the Skylight Otel agent. Alternatively, it can be set to a string indicating the reason for ignoring the trace, which may be shown in the agent logs.

### Ignoring a Span and its children

You can omit a span and its children from a trace with one of these Skylight-specific attributes:

* `$scope[skylight.ignore]`
* `$span[skylight.ignore]`
* `$event[skylight.ignore]`

If `$scope[skylight.ignore]` is set, and its value is `true` (not the string `"true"`!), then all spans under that instrumentation scope will be discarded from the trace. Alternatively, it can be set to a string indicating the reason for ignoring the span, which may be shown in the agent logs.

Otherwise, if the attribute is set to `true` at the `$span` or `$event` level, that specific span and its children will be discarded.

[otel-semconv]: https://opentelemetry.io/docs/specs/semconv/
