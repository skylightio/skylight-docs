---
title: Architecture
description: Learn how the Skylight Otel agent works under-the-hood and what each component does.
---

## Skylight for Ruby

Traditionally, Skylight natively supported Ruby and Rails applications. The classic Skylight agent deeply integrates with the Ruby language and its libraries. Simply by adding the `skylight` gem and deploying your application, you can immediately pick up deep and actionable insights into the application's performances.

To accomplish this, the code included in the classic Skylight agent can be separated into three categories.

### Instrumentation

Skylight for Ruby is built around the `ActiveSupport::Notifications` (AS::N) instrumentation framework.

Typically, library authors bundle Ruby code in their libraries to integrate with AS::N, such that during normal usage, they will emit events into AS::N with details about the operations performed (e.g. a database query in Active Record) and timing information.

While we are sometimes involved in contributing the original instrumentation code, the code generally lives within the library and is maintained by the library authors.

In some rare cases, when a library does not come with built-in AS::N instrumentation, or if the instrumentation is buggy or lacks details, the classic Skylight agent has the ability to inject the necessary code at runtime.

### Collection

`ActiveSupport::Notification` events are emitted as the operations happen, similar to log messages but with associated metadata. By themselves, they are limited in their usefulness as they do not convey contextual information around the operation.

The classic Skylight agent bridges this gap by subscribing to the individual events and assembling the disjoint events into higher-level _traces_, which records the ordering and hierarchy of events within the context of a single request or a background job.

In the process, it extracts data relevant to Skylight and discards the rest to free up memory as soon as possible. It also sanitizes the collected information to remove request-specific details (e.g. the parameters to a SQL query). That way, no sensitive data leave your servers, and the collected data can be aggregated in a useful manner on our backend.

The AS::N subscribers, normalizers, are written in Ruby, while the trace-building and sanitization code are primarily written in Rust for efficiency.

### Submission

Once we have fully assembled a trace, it needs to be submitted to the Skylight backend for aggregation.

In the classic Skylight agent, this is handled by a daemon process written in Rust. It handles everything involved with transmitting traces to the backend, including authentication, encoding, compression, batching, maintaining connections, retrying, etc.

This daemon process is managed transparently by the agent. If multiple Ruby application processes exists on the same server, they will coordinate and share a single instance of the daemon. The daemon process will exit shortly after the last application process exits.

### Conclusion

The classic Skylight Ruby agent packages these components together into the `skylight` gem, which is how we are able to provide the seamless experience our Ruby and Rails customers know and love.

Of course, this is not the end of the line. Once the reports make it to our backend, the rest of the Skylight magic kicks in to process and store them in a way that can be efficiently queried by the Skylight dashboard.

## Skylight for OpenTelemetry

While we love the Ruby ecosystem, some of our Ruby customers (including ourselves!) operate applications in a mix of languages for one reason or another. To better serve our polyglot customers and to reach new customers, we have built a new Skylight agent for OpenTelemetry.

[OpenTelemetry][otel] is an emerging industry standard for instrumenting both library and application code [across a variety of ecosystems][otel-languages].

It has some similarities to `ActiveSupport::Notification` in that it defines a framework that library authors can integrate to provide instrumentation in a standardized way, but also takes things to the next level by baking in first-class hierarchal traces and maintaining a [semantic convention][otel-semconv] to standardize how metadata should be included and interpreted.

In light of these developments, the Skylight Otel agent works quite differently compared to the classic Skylight agent for Ruby.

The Skylight OTel agent is a piece of custom software written entirely in Rust to be as reliable and efficient as possible. Rather than being bundled with and deployed together with your application, the Skylight OTel agent is a standalone binary that lives alongside your application. It runs as a separate process and listens for telemetry data on a local network port. Once it is setup, your application can be configured to export data to this agent over the [OpenTelemetry Protocol (OTLP)][otlp].

Fundamentally, in order for Skylight to function, we still need to handle the same general tasks in the classic Ruby agent, but these responsibilities are assigned differently.

### Instrumentation

With Otel, Skylight is no longer involved with the instrumenting code and the generation of telemetry data. The OpenTelemetry project define standards on the expected format of the data, which are then implemented in [language-specific "SDK"s][otel-languages] that both library and application authors can integrate to emit telemetry data in the compliant format.

You would need to first integrate the appropriate Otel SDK into your application. The specific steps can be found on the [official website][otel-languages] and are different for each language, but generally involves installing a few packages with your language's package manager, and adding a few lines of bootstrap/configuration code. Unlike with the classic Ruby agent, Skylight cannot automatically do this for you, though we are here to assist if you need help.

Also unlike in the classic Ruby agent, if a library does not come with Otel integration, we do not have the ability to inject instrumentation code at runtime. We are only able to consume the data your application emits. We also rely on the emitted data adhering to the [semantic convention][otel-semconv], though cases where the data exists but differs from the conventional format, we do have the ability to correct for that (see [Normalization](#normalization) below).

### Collection

#### OTLP Export

The first step is to get your application to "talk to" the Skylight Otel agent. In OTel terminology, your application needs to *export* its *traces* to the *OTLP endpoint* that the Skylight Otel agent listens on.

In the previous section, we discussed installing an Otel SDK for your language so that your application emits instrumentation events during its normal operation. Ultimately, the goal is to get these out of your application to _somewhere else_. This is what it means to *export* data in Otel.

Historically, there are many different ways to export these data, so you may come across the concept of a configurable *exporter*, which is an adapter written for that specific language/SDK to get the data into the desirable format and destination.

These days, the Otel community is standardizing on a single format and protocol for this purpose – the [OpenTelemetry Protocol (OTLP)][otlp]. It is "native" to Otel in that it requires minimal work to encode OTel data into this format and is implemented in every Otel SDK. This is the protocol the Skylight Otel agent implements.

While OTLP is the defacto standard, in some SDKs, it may be a separately installable package for modularity reasons and may need to be enabled explicitly, but it tends to be covered prominently in the SDK documentation.

Beyond that, you shouldn't need to configure much else. By default, the Skylight Otel agent supports both OTLP over both HTTP and gRPC, and it listens on the default OTLP ports and endpoints, which should align well with the default configurations in all SDKs.

In some documentation, you may encounter mentions of and instructions to set up the [OpenTelemetry Collector][otel-collector]. When using Skylight for OpenTelemetry, **using the OpenTelemetry Collector is not necessary**.

If you are just getting started, we suggest skipping the Collector. However, if you are already set up to use the OpenTelemetry Collector or have other reasons to use it, they can be used together. Refer to the dedicated section on the [OpenTelemetry Collector](./opentelemetry-collector) for more details.

#### Normalization

In a perfect world, the data exported by your application will be pristine, diligently compliant with the [semantic convention][otel-semconv] and comes with exactly the right information for useful aggregation.

In our experience, this is rarely the case. For one thing, the Otel conventions evolve quickly, and newly standardized attributes can take a long time to propagate. At other times, new attributes may remain in "experimental" status for a long time, and Skylight may hold off on adopting them until things fully stabilize. Yet, sometimes a library may be over instrumented and produces too many noisy unhelpful spans.

Whatever the case may be, this is where the "normalization" step comes in and is a major feature of the Skylight Otel agent. There is a lot to cover here, so we have a [dedicated section](./normalizers) for it. At a high level, this allows you to define rules that filters and transforms incoming Otel data, fixing them up before Skylight sees them, so that you can get the most out of Skylight.

#### Buffering

Even though Otel has built-in hierarchal traces, the instrumentation spans are emitted in real time as the operations occur. The SDKs generally do not wait for traces to be completely assembled before exporting the individual spans, particularly for long-running requests and background jobs.

To account for this, the Skylight Otel agent is also responsible for buffering spans until everything has been received, before sending it off to our backend.

To minimize memory usage, the Otel agent runs the normalization step and extracts only data relevant to Skylight prior to holding the spans in the buffer, allowing more memory to be freed up.

Generally, this is not something you need to worry about, but there are [configurations](./configurations) available for fine-tune the buffering behavior.

### Submission

Just like the Ruby agent, when it comes time to sending off fully assembled traces, the Otel agent handles the same responsibilities – authentication, encoding, compression, batching, maintaining connections, retrying, etc. In fact, this part of the agent is identical to the classic Ruby agent and shares the exact same battle-tested Rust code.

### Conclusion

Beyond these differences in the agent, Skylight for Ruby and Skylight for Otel shares the same backend infrastructure and the same intuitive dashboard UI.

Note that the Skylight Otel agent is not meant to replace the classic Ruby agent. As seen in this comparison, the classic agent has are a number of advantages in Ruby applications which are only possible thanks to the deeper language-specific integration. It provides a smoother experience and requires fewer configuration.

While it is possible to use the Otel agent with Ruby applications, unless you have already adopted Otel for other reasons and is already set up for it, the classic Ruby agent is what we continue to recommend.

[otel]: https://opentelemetry.io
[otel-collector]: https://opentelemetry.io/docs/collector/
[otel-languages]: https://opentelemetry.io/docs/languages/
[otel-semconv]: https://opentelemetry.io/docs/specs/semconv/
[otlp]: https://opentelemetry.io/docs/specs/otel/protocol/
