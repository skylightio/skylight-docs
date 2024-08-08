---
title: Configurations
description: Configure the Skylight Otel agent
---

The Skylight Otel agent can be configured using a TOML file or environment variables, or some combination of both, with environment variables taking priority.

## TOML Config File

When launching the `skylight` binary, it will look for `skylight.toml` config file from the current working directory. This file is optional, as the agent is configured with reasonable default values. If present, it is expected to look something like this:

```toml
[server]
# Listen for HTTP export requests on port 8123, instead of the default 4318
http_port = 8123

[traces]
# Discard traces over an hour long
max_duration = "1h"
```

You can also launch the agent with an alternate location for the config file:

```bash
skylight --config /some/path/config.toml
```

The config file is in [TOML][toml] format, which is designed to be easy to read. As such, there are often equivalent ways to express the same item for readability. For instance, the example above is equivalent to the following:

```toml
# Listen for HTTP export requests on port 8123, instead of the default 4318
server.http_port = 8123

# Discard traces over an hour long
traces.max_duration = "1h"
```

See the [TOML documentation][toml-spec] for more details.

We encourage using the more grouped tabular format (first example) for readability. But to avoid any ambiguity, this documentation will refer to the config keys by their full paths, as in the second example.

## Environment Variables

Most config values in the TOML config can also be controlled by an equivalent environment variable. For example:

```bash
SKYLIGHT_OTLP_HTTP_PORT=8123 SKYLIGHT_TRACE_MAX_DURATION=1h skylight
```

This will launch the Skylight Otel agent with the HTTP port set to `8123` and the maximum trace duration set to one hour.

Environment variables take priority over the same setting in the TOML config file, if present. So, the agent will use the HTTP port and maximum trace duration as specified here _regardless_ of the values of `server.http_port` and `traces.max_duration` in the TOML config. If there are other keys specified in the TOML config they will continue to take effect.

## Configuration Options

### Authentication

#### `authentication`

* Environment Variable: `SKYLIGHT_AUTHENTICATION`
* Default Value: (none)

The Skylight authentication token to use for connecting to the Skylight backend and to uniquely identify the Skylight app where the traces belong.

This serves as the default token for all exported traces. However, it can also be specified (or overridden) when traces are sent, by configuring the Otel SDK in the application to send a `Authorization: Bearer skylight-toke-here` header on each export request.

On most SDKs, this can be set with the `OTEL_EXPORTER_OTLP_HEADERS` environment variable.

### Server Config

#### `server.grpc_port`

* Environment Variable: `SKYLIGHT_OTLP_GRPC_PORT`
* Default Value: `4317`

The network port to listen for gRPC OTLP export requests.

#### `server.http_port`

* Environment Variable: `SKYLIGHT_OTLP_HTTP_PORT`
* Default Value: `4318`

The network port to listen for HTTP OTLP export requests.

#### `server.bind_address`

* Environment Variable: `SKYLIGHT_OTLP_BIND_ADDRESS`
* Default Value: `127.0.0.1`

The network address to listen for OTLP export requests. The default value `127.0.0.1` implies the Skylight Otel agent can only be reached locally on the same machine.

If you intend on making the agent available to external hosts (i.e. sharing one instance of the agent across multiple servers), you may set this to either to the address of a specific network interface, or `0.0.0.0` to listen on all available network interfaces.

### Normalizers Config

#### `normalizers.directory`

* Environment Variable: `SKYLIGHT_OTLP_NORMALIZER_DIRECTORY`
* Default Value: `./normalizers`

Where to look for additional user-defined normalizers. By default, the agent will optionally search for normalizers in the `./normalizers` directory. If present, it will attempt to load all `.toml` files recursively. Note that relative paths are resolved relative to the location of the `config.toml` file.

#### `normalizers.disable`

* Environment Variable: `SKYLIGHT_OTLP_DISABLE_NORMALIZER_RULES`
* Default Value: (none)

Disable one of more built-in normalizers by ID.

In the TOML config file, this is specified as an array of strings, the IDs for the normalizers to disable. If specified as an environment variable, this is specified as a comma-separated string.

#### `normalizers.rules`

* Environment Variable: N/A
* Default Value: (none)

This key allows you to specific additional user-defined normalizer inline in the TOML config file as an array, in lieu of or in addition to standalone TOML files in the `normalizers` directory.

For example:

```toml
# Other configs
[server]
http_port = 8123

[normalizer]
disable = ["..."]

[[normalizer.rules]]
match = { key = "$span[my.key]", value = "my value" }
"$span[my.key]" = "different value"

[[normalizer.rules]]
match = true
"$span[other.key]" = "other value"
```

### Traces Config

#### `traces.ignore`

* Environment Variable (use only one of these aliases):
    * `SKYLIGHT_IGNORED_TRACE`
    * `SKYLIGHT_IGNORED_TRACES`
* Default Value: (none)

Ignore traces with the given names.

In the TOML config file, this is specified as an array of strings, the trace names to ignore. If specified as an environment variable, this is specified as a comma-separated string.

Historically, trace name was also known as "endpoint name" so these legacy aliases, while not preferred, may also be used instead:

* Legacy TOML Alias: `traces.ignored_endpoints`
* Legacy Environment Variables:
    * `SKYLIGHT_IGNORED_ENDPOINT`
    * `SKYLIGHT_IGNORED_ENDPOINTS`

#### `traces.max_duration`

* Environment Variable: `SKYLIGHT_TRACE_MAX_DURATION`
* Default Value: `4hr`

The maximum duration of a trace. Traces exceeding this duration are discarded and not sent to the backend.

Note that this value cannot exceed six hours. By default, this is set to four hours to allow for long-running background jobs.

When setting this value, a unit must be provided following the numeric value. In both the TOML config file and the environment variable, the following units are available:

* Hours: `6h`, `6hr`, `6hrs`
* Minutes: `30m`, `30min`, `30mins`
* Seconds: `5s`, `5sec`, `5secs`

#### `trace.inactivity_timeout`

* Environment Variable: `SKYLIGHT_TRACE_INACTIVITY_TIMEOUT`
* Default Value: `5min`

The maximum duration of inactivity before discarding a trace. In other words, when no activity has been recorded for a particular trace ID with incomplete spans, it will be discarded and its memory freed up.

Most language-specific Otel SDKs export spans as they are generated, rather than accumulating them in-memory in the application process until the full trace is assembled. In turns this means the Skylight Otel Agent has to assume to responsibility of buffering incomplete traces until all its spans are received.

In rare cases, if the application crashes after partially exporting a trace, or is otherwise misconfigured and never finishes the trace, this causes the Skylight Otel Agent to retain these partial traces which needlessly consumes memory. The inactivity timeout allows these partial traces to be discarded when they are no longer needed to free up memory.

On the other hand, if this value is set too low, it may inadvertently cause valid traces to be dropped prematurely. If you have long-running background jobs with short bursts of activity but long duration of inactivity in-between, you may need to adjust this setting.

When setting this value, a unit must be provided following the numeric value. In both the TOML config file and the environment variable, the following units are available:

* Hours: `6h`, `6hr`, `6hrs`
* Minutes: `30m`, `30min`, `30mins`
* Seconds: `5s`, `5sec`, `5secs`

#### `traces.finalization_window`

* Environment Variable: `SKYLIGHT_TRACE_FINALIZATION_WINDOW`
* Default Value: `10sec`

A short delay to wait after complete traces are received, before sending it off to the backend.

Most language-specific Otel SDKs export spans as they are generated, rather than accumulating them in-memory in the application process until the full trace is assembled. In turns this means the Skylight Otel Agent has to assume to responsibility of buffering incomplete traces until all its spans are received.

The only way to infer that a trace is "complete" is when receiving its "root span" – i.e. a span with no parent. However, in rare cases, export requests can arrive out-of-order, causing the root span to be received before all its child spans are received. To account for this, this setting allows for a short waiting period is added after receiving the root span.

When setting this value, a unit must be provided following the numeric value. In both the TOML config file and the environment variable, the following units are available:

* Hours: `6h`, `6hr`, `6hrs`
* Minutes: `30m`, `30min`, `30mins`
* Seconds: `5s`, `5sec`, `5secs`

[toml]: https://toml.io/en/
[toml-spec]: https://toml.io/en/v1.0.0
