---
title: OpenTelemetry Collector
description: Using Skylight with the OpenTelemetry Collector
---

The [OpenTelemetry Collector][otel-collector] is a piece of software maintained by the Otel project. It is open-source and is written in Go.

### What does the Collector do?

The Collector is intended to serve as a local proxy between your application and the ultimate destination(s) for your telemetry data.

Typically, the Otel SDK for your language can be configured to export telemetry data over the [OpenTelemetry Protocol (OTLP)][otlp]. OTLP operates over either HTTP or gRPC, using a specific protobuf format for the data interchange.

If you are using a tool or a vendor that provides a native OTLP endpoint, you may be tempted to configure your SDK to directly export to the remote endpoint, as in `OTEL_EXPORTER_OTLP_ENDPOINT="https://ingest.my-data-vendor.example"`.

This approach can work as a quick way to get up-and-running, it comes with some significant drawbacks:

1. You can only export data to one destination. If you want to use multiple tools (e.g. using Skylight for high-level aggregated summaries and another database to retain the raw data), you are out of luck.

2. The communication with the remote endpoint is limited to the OTLP export request plus some additional headers. If your tool requires, say, a more elaborate authentication scheme, then you may be out of luck.

3. You may not want to export the raw data as-is, as it may contain sensitive data or does not fully match the desired format.

4. Your SDK is responsible for transporting the data to the remote destination, and it must correctly handle everything from DNS lookup, TLS certificate validations, encoding, compression, buffering, retrying, etc.

   While this is not exactly rocket science, the handling of these aspects varies across languages and SDK implementations. It also requires more work inside your application's process and may take resources away from your running your application code. Sometimes it may also cause excess memory consumption and strains on the garbage collector when the remote server is slow or unreliable.

The OpenTelemetry Collector is designed to solve these problems efficiently.

Rather than having your SDK export the data directly to the remote destination, you would run an instance of the Collector locally. Typically, you would run it on the same machine, or on a nearby node within the same local network. This simplifies the networking responsibilities taken on by the application process and removes the risks and fragilities that comes with communicating with an remote endpoint.

It also allows for the data to be transformed (e.g. dropping sensitive data) before they are exported.

Finally, it allows for exporting the same data to multiple destinations, possibly with different processing rules for each destination. This allows multiple tools to be used at the same time.

### Do you need the Collector?

For all the reasons mentioned above, it is generally a good idea to use the Collector when using Otel in production. However, this is not necessary when using Skylight with Otel.

The Skylight Otel agent is designed to solve most of these same problems:

1. Just like the Collector, the Skylight Otel agent is designed to run locally along side your application. This takes the networking responsibilities out of your application process into the Skylight Otel agent, which shares the same battle-tested networking code with the classic Skylight Ruby agent.

2. Because Skylight operates on the principle of aggregation, the agent is designed to send only aggregable data to the backend, which should exclude sensitive private data. It also comes with a mechanism (custom normalizers) for configuring additional rules for this purpose.

Therefore, if Skylight is the only destination for your telemetry data, you do not need the OpenTelemetry Collector to achieve these benefits.

### Can I use Skylight with the Collector?

If you want to use other tools alongside Skylight, or if you are already set up to use the OpenTelemetry Collector, it can certainly be used together with Skylight as well.

In this scenario, you would configure your SDK to export to the Collector, and in the Collector configuration, add the Skylight agent as an exporter. Since the Collector is typically listen on the default OTLP ports, you would also have to configure the Skylight Otel agent to run on alternative ports.

This is an example of the Collector config:

```yaml
# otelcol.yaml

receivers:
  # Configure the Collector to listen for OTLP exports from the application
  otlp:
    protocols:
      grpc:
        endpoint: localhost:4317
      http:
        endpoint: localhost:4318

exporters:
  # Configure an export destination to the Skylight Otel agent
  otlphttp/skylight:
    # Make sure the port here matches the agent config
    endpoint: http://localhost:4320
    # Avoid wasting CPU on unnecessary gzip compression
    compression: none
    # If the agent isn't configured with an authentication token,
    # supply one here. Otherwise, this can be left out.
    headers:
      authorization: <YOUR SKYLIGHT APP TOKEN>

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [otlphttp/skylight]
```

And the corresponding Skylight Otel agent config:

```toml
# skylight.toml

[server]
grpc_port = 4319
http_port = 4320
```

[otlp]: https://opentelemetry.io/docs/specs/otel/protocol/
[otel-collector]: https://opentelemetry.io/docs/collector/
