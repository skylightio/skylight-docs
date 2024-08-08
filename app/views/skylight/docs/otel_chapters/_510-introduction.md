---
title: Introduction
description: Using Skylight beyond Ruby applications with OpenTelemetry.
---

We are happy to announce Skylight for [OpenTelemetry (OTel)][otel]. This allows us to reach customers with applications running in environments outside of our traditional Ruby and Rails roots, such as Python, JavaScript, Rust, Go, [just to name a few][otel-languages].

## Quick Start

<%= render layout: "note" do %>
  These steps assumes Skylight is the only tool that consumes Otel data from your application. If you are also using other Otel tools, refer to [these instructions](./opentelemetry-collector) for using Skylight with the OpenTelemetry Collector.
<% end %>

If you are new to OpenTelemetry, you may want to first read the next chapter in this documentation for an quick introduction.

Here are the general steps for getting Skylight up-and-running with Otel:

1. Integrate the appropriate [language-specific Otel SDK][otel-languages] into your application.

2. [Crate a app on Skylight][skylight-setup-otel] and obtain an authentication token.

3. [Download the latest release][skylight-otel-download] of the Skylight Otel agent for your platform into a suitable location on the server.

4. Run the Skylight Otel agent on your server alongside the application, with the authentication token obtained from above:

   ```bash
   SKYLIGHT_AUTHENTICATION="<your token here>" ./skylight
   ```

   The agent will listen for trace export requests on the default OTLP ports and endpoints, specifically:

   * gRPC: `http://localhost:4317`
   * HTTP/protobuf: `http://localhost:4318/v1/traces`

5. Configure the Otel SDK in your application to export its **traces** using the [OTLP exporter][otlp-exporter] (the agent does not accept metrics and logs).

   While OTLP is usually the default exporter, for modularity reasons, some SDKs require installing additional packages to enable this functionality.

   The configuration may look like this:

   ```bash
   export OTEL_SERVICE_NAME="My App"
   export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=production"
   export OTEL_TRACES_EXPORTER="otlp"
   export OTEL_METRICS_EXPORTER="none"
   export OTEL_LOGS_EXPORTER="none"

   # Run the application with the above environment variables
   ./my-app
   ```

<!-- TODO: heroku -->
<!-- TODO: lambda -->

[otel]: https://opentelemetry.io
[otel-languages]: https://opentelemetry.io/docs/languages/
[otlp-exporter]: https://opentelemetry.io/docs/languages/sdk-configuration/otlp-exporter/
[skylight-setup-otel]: https://www.skylight.io/app/setup/manual?otel=true
[skylight-otel-download]: https://github.com/tildeio/skylight-otlp/releases
