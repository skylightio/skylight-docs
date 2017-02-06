---
Title: Running Skylight
Description: Find out if you can run Skylight in your environment.
Order: 1
---

# Running Skylight

Last updated January 1, 2017


## Requirements

### Ruby Version

#### Minimum: 1.9.2+, Preferred: 2.1+

The agent will run with 1.9.2+. However, 2.1+ is required for memory allocation tracking.

For the curious, our CI currently is testing against 1.9.2, 1.9.3, 2.0.0, 2.1.6, and 2.2.3. Intermediate versions are expected to work as well.


### Framework

Skylight has built in integration for Rails, Sinatra, and Grape.


###  Rails

#### Minimum: 3.0+

Skylight utilizes Rails’ Railties to autoload. It then watches the built `ActiveSupport::Notifications` to get information about controller actions, database queries, view rendering, and more.


###  Sinatra

#### Minimum: 1.2+

Not running Rails? We also support Sinatra apps, though the default instrumentation will be less detailed. By default, we’ll recognize your Sinatra routes and also instrument any [supported gems](instrumentation#available-instrumentation-options). You can also add [custom instrumentation](instrumentation#custom-app-instrumentation).


###  Grape

#### Minimum: 0.10+, Preferred: 0.13+

We support Grape standalone as well as embedded in Rails and Sinatra. We recognize endpoints and instrument rendering and filters. As of version 0.13, ActiveSupport::Notifications is built-in to Grape making the instrumentation even more streamlined.


## Server Requirements

We aim to support all *nix servers. Just add the gem to your Gemfile, add the configuration, then deploy as you normally would. You can also run the agent locally on OS X for testing, if desired. See the [Getting Set Up](/getting_set_up) section for more information.


### Heroku

The agent runs great on Heroku. No special actions required.


## Compatibility with Other Profilers and Monitoring Tools

Skylight plays nice with other profilers and monitoring solutions, including New Relic. Many of our customers run multiple tools with success! Go ahead and compare :)


## Resource Overhead

The Skylight agent is written primarily in [Rust](https://www.rust-lang.org/), a systems programming language on par with C. This means we have a very low overhead so it’s safe to run Skylight in production, even in memory limited environments like Heroku.
