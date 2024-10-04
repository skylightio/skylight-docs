---
title: OpenTelemetry Concepts
description: A quick reference of OpenTelemetry terminologies as they relate to Skylight.
---

## Key Concepts

Here are some key concepts in OpenTelemetry that you will encounter when using when using Skylight for Otel.

### Trace

A trace represents a complete transaction in your application. In applications using Skylight, this can either be a web request or a background job run.

In terms of its data – a trace is a hierarchical data structure containing one or more [_spans_](#span).

In the Skylight UI, all related traces of the same kind are grouped together and merged into an _aggregate trace_ to give you a big picture understanding.

<%= image_tag 'skylight/docs/features/endpoint-view.png', alt: 'Screenshot of an aggregate trace in the Skylight UI' %>

### Span

Spans are the building block of [_traces_](#trace). It represents the time taken for an operation to complete, such as time time spent executing a database query or rendering a template.

At minimum, every span has a _name_ and records the start and end time of the operation, but it can also carry additional metadata in its [_attributes_](#attribute).

Spans can also be nested, which is what makes traces hierarchical. Every trace has exactly one _root span_, which represents the total time for completing the entire transaction. From there, each span can have zero or more children. For example, a span representing an external HTTP request may contain additional nested child spans that further breaks down the time taken for DNS lookup, waiting for the server to generate a respond, etc.

In the Skylight UI, these corresponds to the _aggregate spans_ in the _aggregate trace_. Essentially, they inform you the time it typically takes to complete the same operation across many similar transactions within the selected time frame.

<%= image_tag 'skylight/docs/features/child-events.png', alt: 'Screenshot showing an aggregate span in the Skylight UI' %>

Where applicable, we also visually distinguish between different types of spans and shows any relevant metadata. For example, database spans are colored green and may have the sanitized database query attached.

<%= image_tag 'skylight/docs/features/detail-card.png', alt: 'Screenshot of a database span with the sanitized query attached', style: img_width(700) %>

### Attribute

Attributes are structured metadata in the form of key-value pairs that can be attached to [_spans_](#span) and other kinds of telemetry nodes – [_resource_](#resource), [_instrumentation scope_](#scope) and [_span events_](#event).

Every attribute has a string key, such as `"http.request.method"`. Attributes are "flat", but conventionally uses dots in the key to denote _namespaces_, which groups together related attributes. For example, attributes starting with "http." indicates they contains metadata related to the HTTP protocol.

Attribute values are typically strings, but could also be numbers or booleans. The specification also permits arrays and bytes, but those are not supported by Skylight and are automatically dropped.

The [_Semantic Convention_](#semantic-convention) governs both the naming of attributes as well as the type and format of the attribute values.

Skylight does not automatically capture or send all incoming attributes. In fact, most attributes are simply dropped in the agent as soon as they are encountered. In Skylight, we are only interested in preserving attributes that can be usefully aggregated across many transactions – those that are known not to contain sensitive or request-specific data. Dropping unused attributes early-on results in memory savings.

### Semantic Convention

The [OpenTelemetry Semantic Convention][otel-semconv] is a standard published by the OpenTelemetry project with recommendations on how SDKs and libraries should name and format their attributes when including certain well-known types of metadata.

For example, a span representing a SQL database query may include attributes such as:

* `"db.system"`: `"postgresql"`
* `"db.query.text"`: `"SELECT * FROM Table WHERE username = ?"`

Skylight relies on this standard to interpret the incoming trace data and make decisions on whether to keep an attribute, and whether/how to sanitize its value.

This is a _rapidly evolving_ standard. For instance, as of writing, the `"db.query.text"` attribute is recommended for _sanitized_ version of the query, whereas a slightly older version of the standard recommended a (now deprecated) `"db.statement"` attribute which contains the full unsanitized version of the query.

Naturally, these changes takes time to propagate across the ecosystem, and the spans emitted by the libraries you use may not fully adhere to latest version of the convention. This is why the Skylight Otel agent has a [normalizer system](./normalizers) to fix up these kind of issues.

### Language-specific SDK

A language-specific SDK (e.g. the [Python Otel SDK][otel-python-sdk]) concretely implements the Otel concepts in your language of choice, exposing language-appropriate APIs you can call to instrument your own code. This will emit telemetry data that can be consumed by the rest of the Otel ecosystem once _exported_ out of the application process.

In most languages, this comes in the form of a library package installable from your language's package manager.

### OTLP

The [OpenTelemetry Protocol (OTLP)][otlp] is the default and native way for applications to export telemetry data into an external destination. It is "native" in that it is designed with thr Otel telemetry data model in mind, thus requiring minimal work in the host language to encode into this format. It is also implemented in every Otel SDK.

The protocol works over either HTTP or gRPC transport, and expects the data to be encoded in a certain protobuf format. The Skylight Otel agent implements both the HTTP and gRPC version of this protocol.

## Additional Concepts

Here are some less commonly encountered concepts in OpenTelemetry when using Skylight for Otel.

### Resource

A resource provides information about the entity producing the spans, such as the host machine, application process, and service.

You may also be given the option to configure _resource attributes_, which are _attributes_ attached globally to the resource instead of individual spans.

### Scope

A instrumentation scope identifies the library, package, or module producing the span, often represented by a name and version. It can also have additional _attributes_ attached.

These are not directly consumed by Skylight. However, it allows for precisely targeting spans in normalizer rules.

### Event

A span event is a special kind of children attached to a span. They are similar to spans in that they have a name and zero or more attributes. However, unlike spans, they do not represent passage of time, thus do not have a start and end time.

These are not directly consumed by Skylight. However, libraries sometimes emit useful information in the form of events, and the normalizer system allows you to extract these information into the associated span.

### Metrics

In Otel, a metric is a long-running measurement, such as a counter for the total number of requests.

These are not supported by Skylight and the Skylight Otel agent does not implement the OTLP endpoint for receiving metrics data.

### Log

Logs are exactly what they sound like – a timestamped text message.

These are not supported by Skylight and the Skylight Otel agent does not implement the OTLP endpoint for receiving logs data.

### Baggage and Context

Context is the terminology used in Otel for passing data across services when making an external request, and baggage are similar to attributes attached to the context.

Neither are supported by Skylight and the Skylight Otel agent does not implement the OTLP endpoint for receiving baggage data.

### Signal

Signal is the terminology used by OpenTelemetry to collectively refers to the categories of telemetry data – traces, metrics, logs, baggage. Of which, only traces are relevant to Skylight.

### Exporter

An adapter for exporting telemetry data from the application to an outside destination.

This is somewhat of a legacy concept – before [_OTLP_](#otlp) was widely adopted, we may have implemented a "Skylight Exporter" in select language-specific SDKs, which would require dedicating resources to implementing the same code once per each language we wish to support.

With OTLP, we are able to side-step that altogether. For the purpose of using Skylight with Otel, you would simply use the standard OTLP exporter rather than a Skylight-specific one.

### Collector

The [OpenTelemetry Collector][otel-collector] is a piece of software maintained by the Otel project. It is open-source and is written in Go. It implements OTLP and is intended to serve as a local proxy between your application and the ultimate destination for your telemetry data.

The official documentation often recommends setting up a local collector when using Otel in production. However, this is not a hard requirement and is not necessary when using Skylight with Otel.

The main benefit of using the collector is to allow the application to offload telemetry data to an external process quickly, reliably and securely. This is as opposed to configuring the application to export its telemetry data to a remote endpoint over the public Internet.

There are numerous downsides to the latter (direct export) approach. For one thing, sensitive data may travel over the public Internet. Also, if the remote service itself, or the path on the way there, is slow or unreliable, it may cause increased memory usage and slowdowns in the host application.

The Skylight Otel agent implements the same architecture and serves the same role as a local collector for those purposes, and so none of those issues apply when exporting directly to a local Skylight Otel agent.

That being said, the collector offers additional features that may be useful to you. For example, it allows telemetry data to be sent to multiple destinations at the same time. If you are interested in using the OpenTelemetry Collector, we have a [dedicated article on that topic](./opentelemetry-collector).

[otel-collector]: https://opentelemetry.io/docs/collector/
[otel-semconv]: https://opentelemetry.io/docs/specs/semconv/
[otel-python-sdk]: https://github.com/open-telemetry/opentelemetry-python
[otlp]: https://opentelemetry.io/docs/specs/otel/protocol/
