---
title: Getting Set Up
description: Install, configure, and deploy the agent.
order: 2
updated: January 1, 2017
---

## Installing the Agent

```ruby
# Gemfile
gem 'skylight'
```

(You should make sure the gem is available in all of your environments. See the information about individual installations below to find out how to make sure the agent runs in the environments you care about.)

Then run:

```sh
bundle install
bundle exec skylight setup {SETUP_TOKEN}
```

To get the setup token, head over to [http://skylight.io/app/setup]().


## Deployment

Once you’ve run `skylight setup` you’ll need to get the configuration to your server. For this you have two options:

* check in the `config/skylight.yml` file (which is automatically generated and includes the necessary auth token) OR
* set the appropriate ENV vars, at the minimum `SKYLIGHT_AUTHENTICATION`. See below for more information.

After this, all you need to do is run your standard deployment process.


### Heroku

For Heroku, setup is as simple as setting the desired ENV vars and pushing your repo. Nothing fancy required!


## Agent Configuration

Though, all that’s necessary to set is the authentication token, there are a number of other configuration options available.


### Setting Configuration Variables

The automatically generated configuration file `config/skylight.yml` looks like this:

```yaml
---
# The authentication token used when reporting data back to the Skylight
# service.
#
# Required in production.
authentication: <authentication token>

# Path to the Skylight log file
log_file: log/foo.log

# Path to store daemon-related temporary files
daemon.sockdir_path: /var/run/myapp

# Environment specific configuration. Any variable can be scoped by an
# environment and will take precedence over a default.
# NOTE: Currently this is only correctly utilized in Rails apps.
production:

  authentication: <production auth token>

staging:

  authentication: <staging auth token>
```

The configuration file will be parsed as ERB so you can add additional logic if desired.

Alternatively, configuration can be set via ENV vars. In general, the ENV vars are capitalized versions of the YAML versions prefixed with `SKYLIGHT_`, e.g. `SKYLIGHT_AUTHENTICATION`, `SKYLIGHT_LOG_FILE`.


### General Options

* `authentication` (required) — The authentication token for the app. Available on the application settings page under the ‘Apps’ section.
* `log_file` — Change the location of the Skylight log. By default this is `log/skylight`.log with Rails or STDOUT otherwise.
* `daemon.sockdir_path` – The path where the socket file for the daemon is created. In general you will not need to change this. However, if you’re using an NFS mount (say with Vagrant) you’ll need to point this to a non-NFS location.


####  Ignoring heartbeat endpoints

Sometimes, an endpoint exists solely for your load-balancer to determine whether your Rails process is up.

If you would like to ignore this endpoint, you may add the `SKYLIGHT_IGNORED_ENDPOINTS` environment variable. Once configured, Skylight will not collect instrumentation and requests to this endpoint will not be counted in the application’s usage or be represented as part of the application’s aggregated response time and RPM graphs.

The name of the endpoint can be found in the endpoints list on your Skylight application dashboard. For Rails actions, it will be `Controller#action`, for Sinatra it will be `VERB path`, and for Grape it will be `Module [VERB] path`. Always use the name in list UI if you’re unsure.

An example of the environment variable would be: `SKYLIGHT_IGNORED_ENDPOINTS=HeartbeatController#status,OtherController#heartbeat`

You may also set the ignored heartbeat endpoint using the YAML configuration file as follows:

```yaml
ignored_endpoints:
  - HeartbeatController#status
  - OtherController#heartbeat
```


###  Rails

There are also additional configuration options that can be set in the Rails environment. Unless otherwise noted, these settings should be added to `config/application.rb`. Do not attempt to set them via initializers as Skylight starts before initializers are run.

Skylight performs setup when the gem is required, at which time Rails will be detected and tapped into. However, you may find you have to manually require `skylight/railtie` if you need to load the Skylight gem before Rails.


####  Environments

By default, the Skylight agent only enables itself in the production Rails environment. If, for example, you wish to enable Skylight in staging, you can do the following:

```ruby
# config/application.rb
config.skylight.environments += ['staging']
```

Also be sure and check out the rest of our [documentation on setting up multiple environments](#setting-up-multiple-environments).


####  Logger

Perhaps you might want to tell Skylight to use a specific logger. This can be achieved like this:

```ruby
# config/application.rb
config.skylight.logger = Logger.new(STDOUT)
```

####  Probes

In order to instrument other libraries outside of Rails, the agent includes probes which are only activated if the related files are required. Since this is an experimental feature, it’s opt-in for now.

We currently have probes for **Net::HTTP**, **ActionView**, **Grape**, **Excon**, **Redis**, **ActiveModel::Serializers**, **Moped**, **Mongo**, **Sinatra**, **Tilt**, and **Sequel**.

The **Net::HTTP**, **ActionView**, and **Grape** probes are enabled by default.

To enable other probes:

```ruby
# config/application.rb
config.skylight.probes += %w(excon redis active_model_serializers)
```

See the [Instrumentation section](/instrumentation#probes) to learn more about the probes.


### Sinatra

#### In Rails

If your Sinatra app is mounted in Rails, all you have to do is require the correct probes:

```ruby
# config/application.rb
config.skylight.probes += %w(sinatra tilt sequel)
```

See the [Rails configuration instructions](#rails) for more information.


#### Standalone

Skylight works just as well in standalone Sinatra apps, though the instructions are just a touch more involved.

Sinatra apps usually do not require all gems in the Gemfile, so you will want to add a line like this to your main file:

```ruby
require "skylight/sinatra"
```

You will also need to boot up the Skylight agent explicitly:

```ruby
Skylight.start!
```

(If you want to load your configuration from a file instead of from ENV, you can use `Skylight.start!(file: PATH_TO_CONFIG)`.)

You generally do not want to run Skylight in development mode, and the most common way to do that in Sinatra apps is to use the `:production` environment.

```ruby
configure :production do
  require "skylight/sinatra"
  Skylight.start!
end
```

You don’t need to install any middleware manually, or do anything with unicorn forking settings.

> NOTE: Padrino is not currently supported as it differs from base Sinatra in some significant ways. We are investigating adding support in future releases.


### Grape

#### On Rails

If your Grape app is mounted in Rails and is version 0.13+, it works out of the box with no further configuration! Congrats!

If you’re running 0.10 - 0.12 all you have to do is require the following probe:

```ruby
# config/application.rb
config.skylight.probes += ['grape']
```

See the [Rails configuration instructions](#rails) for more information.


####  On Sinatra

If your Grape app is mounted in a Sinatra app, first follow the [Sinatra instructions](#sinatra).

If you’re running Grape 0.13+, that’s all you need to do. For versions 0.10 - 0.12, you’ll also want to add this to your main file:

```ruby
require 'skylight/probes/grape'
```


#### Standalone

Grape apps usually do not require all gems in the `Gemfile`, so you’ll want to begin by adding a line like this to your main file:

```ruby
require "skylight"
```

(If you’re running grape 0.10 - 0.12 or earlier, you’ll also need to explicitly require the probe: `require 'skylight/probes/grape'`.)

You will also need to boot up the Skylight agent explicitly.

```ruby
Skylight.start!
```

(If you want to load your configuration from a file instead of from ENV, you can use `Skylight.start!(file: PATH_TO_CONFIG)`.)

Since you probably don’t want to instrument your app locally, you should set up a conditional to ensure this this is only run in production environments.

Finally, you’ll want to install the Skylight middleware in your base Grape or Rack app with:

```ruby
use Skylight::Middleware
```


## Setting Up Multiple Environments

In many cases, your applications will have two or more production-like environments. These are typically referred to as “production” and “staging”, and you may also have “test”, “QA”, “dev”, etc. environments.

You can configure Skylight to separate data for each of these environments by creating a new application for each, and then configuring Skylight to use the appropriate app on a per-environment basis.

To create a new environment, make a directory using the name you’d like:

```sh
mkdir /tmp/appname-staging
cd /tmp/appname-staging
```

Then follow the instructions available on the app setup screen, running them in this temporary directory intead of in your main Rails app.

If you are using Rails and have not already done so, also be sure to add the new environment to your `application.rb` file if you are using Rails.

This will create a new application on Skylight, using the directory name as the default. You can always change the application’s name via the Skylight web UI.

Once `skylight setup` has finished running, a new `config/skylight.yml` file will be generated containing a new application ID and authentication token.

You’ll need to [configure](#setting-configuration-variables) this new environment with these new credentials.


## Regenerating the App Token

If your application token may have been compromised, you can regenerate it from the [settings page](https://www.skylight.io/app/settings/account).

<img retina="true" style="width: 100%; max-width: 1249px" src="../assets/regenerate-token.png" alt="Screenshot of settings page">

Once you have regenerated the token, you will need to [update your production application](#setting-configuration-variables) with the new token.
