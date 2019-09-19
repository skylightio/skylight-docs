<% agent_version = ENV["SKYLIGHT_AGENT_EDGE_VERSION"] || "4.0.0" %>

Background jobs instrumentation is available with version 4.0.0 (the current version is <%= agent_version %>) and up of the Skylight agent:

```ruby
# Gemfile
gem 'skylight', '~> <%= agent_version %>'
```
