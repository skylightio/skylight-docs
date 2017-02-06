---
<<<<<<< 0664bf38bd973603f286c534e409d3e906ba9562
title: Troubleshooting
last_updated: 2015-12-15
---

Sorry to hear you're having trouble. Below are some troubleshooting steps
you can try. If you're still having trouble, please contact us via e-mail
at [support@skylight.io](mailto:support@skylight.io).

## Skylight was working before, but now I'm only seeing "No requests in this time range" when viewing an app.

You might see this bug if the agent running in your Rails app stops
reporting performance data to Skylight. If you were able to see data
before but it has stopped working recently, restarting your server will
usually fix the issue.

If the agent encounters multiple errors in a short span of time, it will
shut itself down. This is done out of an abundance of caution to ensure
that a potential bug in the agent doesn't bring down your app in
production.

We are working to add more logging to the agent so we can better
diagnose what causes the agent to shutdown and recover gracefully in the
event of an error. If you find this is happening regularly, please let
us know!

## How do I use Skylight if my app is hosted on Heroku?

If you're deployed on Heroku, there's just one command you
need to run to make your Skylight API token available:

    heroku config:set SKYLIGHT_AUTHENTICATION="<token>"

Note that changing a config var in Heroku will cause your application to
restart. Once the app has restarted and handled several requests, you
should begin seeing performance data about your application in Skylight.

For more information about setting Heroku config vars, see
[Configuration and Config Vars](https://devcenter.heroku.com/articles/config-vars)
in the Heroku documentation.

## I'm using Heroku but no data is showing up in Skylight.

First, make sure that there is traffic to your application. If your
Rails app is handling requests, you should start to see data in Skylight
in just a few minutes.

We have received reports of problems running on the `cedar-10` stack.
You should upgrade to the `cedar-14` stack.

If your app is running and has traffic, but you're still not seeing
anything in Skylight, verify that the `skylight` gem is installed and
running properly.

Make sure you are using the latest version of the Skylight gem (0.9.3
when this was written). In the directory for your Rails app, run this
command:

    bundle list | grep skylight

You should see something like the following output:

    * skylight (0.9.3)

If the gem is installed and up-to-date, the next step is to verify that
it is running correctly:

1. In one terminal window, run `heroku logs -t` to show the application
   log.
2. In another terminal window, run `heroku restart` to restart the app.

Keep an eye on the log terminal. If you see an error message stating
that the Skylight agent is missing an authentication token, make sure
that your auth token is set by running:

    heroku config:set SKYLIGHT_AUTHENTICATION="<your token>"
=======
Title: Troubleshooting
Description: Having trouble with the agent? Take a look here.
Order: 5
---

# Troubleshooting

Last updated January 1, 2017

Sorry to hear you’re having trouble. Below are some troubleshooting steps you can try. If you’re still having trouble, please contact us via e-mail at [support@skylight.io](mailto:support@skylight.io).


## Skylight was working before, but now I’m only seeing “No requests in this time range” when viewing an app.

You might see this bug if the agent running in your Rails app stops reporting performance data to Skylight. If you were able to see data before but it has stopped working recently, restarting your server will usually fix the issue.

If the agent encounters multiple errors in a short span of time, it will shut itself down. This is done out of an abundance of caution to ensure that a potential bug in the agent doesn’t bring down your app in production.

We are working to add more logging to the agent so we can better diagnose what causes the agent to shutdown and recover gracefully in the event of an error. If you find this is happening regularly, please let us know!


## How do I use Skylight if my app is hosted on Heroku?

If you’re deployed on Heroku, there’s just one command you need to run to make your Skylight API token available:

```sh
heroku config:set SKYLIGHT_AUTHENTICATION="<token>"
```

Note that changing a config var in Heroku will cause your application to restart. Once the app has restarted and handled several requests, you should begin seeing performance data about your application in Skylight.

For more information about setting Heroku config vars, see [Configuration and Config Vars](https://devcenter.heroku.com/articles/config-vars) in the Heroku documentation.


## I’m using Heroku but no data is showing up in Skylight.

First, make sure that there is traffic to your application. If your Rails app is handling requests, you should start to see data in Skylight in just a few minutes.

We have received reports of problems running on the `cedar-10` stack. You should upgrade to the `cedar-14` stack.

If your app is running and has traffic, but you’re still not seeing anything in Skylight, verify that the `skylight` gem is installed and running properly.

Make sure you are using the latest version of the Skylight gem (0.9.3 when this was written). In the directory for your Rails app, run this command:

```sh
bundle list | grep skylight
```

You should see something like the following output:

```sh
* skylight (0.9.3)
```

If the gem is installed and up-to-date, the next step is to verify that it is running correctly:

 1. In one terminal window, run `heroku logs -t` to show the application log.
 1. In another terminal window, run `heroku restart` to restart the app.

Keep an eye on the log terminal. If you see an error message stating that the Skylight agent is missing an authentication token, make sure that your auth token is set by running:

```sh
heroku config:set SKYLIGHT_AUTHENTICATION="<your token>"
```

>>>>>>> Add source markdown files to be parsed

## I deployed my application, but no data is appearing in Skylight.

### Is your environment correct?

<<<<<<< 0664bf38bd973603f286c534e409d3e906ba9562
Verify that the application is running with the correct Rails
environment. By default, the agent only starts in the `production`
environment, but this can be configured.

To learn how to change what environments Skylight starts in, see
[Railtie Environments](/getting-set-up/#agent-configuration-rails-environments).

### Is the `skylight` gem in the right group?

Verify that, in your app's `Gemfile`, you've added the `skylight`
gem to a group that will be installed in production. For example, if you
add `skylight` to the `development` group, it will not run when you
deploy to production.

### If you're using Sinatra or Grape without Rails, did you follow the installation instructions?

* [Sinatra Instructions](/getting-set-up/#agent-configuration-sinatra)
* [Grape Instructions](/getting-set-up/#agent-configuration-grape)

### Is the sockfile path writable?

By default, Skylight uses your Rails tmp path as the sockfile directory.
In the event that this path isn't writable you should set
`daemon.sockdir_path` in your [config](/getting-set-up/#agent-configuration-setting-configuration-variables).

### Are you using NFS, possibly with Vagrant?

Skylight's socket file can't be located on an NFS mount. Set `daemon.sockdir_path`
in your [config](/getting-set-up/#agent-configuration-setting-configuration-variables)
to a non-NFS path.
=======
Verify that the application is running with the correct Rails environment. By default, the agent only starts in the `production` environment, but this can be configured.

To learn how to change what environments Skylight starts in, see [Railtie Environments](/getting_set_up#rails).


### Is the `skylight` gem in the right group?

Verify that, in your app’s `Gemfile`, you’ve added the `skylight` gem to a group that will be installed in production. For example, if you add `skylight` to the `development` group, it will not run when you deploy to production.


### If you're using Sinatra or Grape without Rails, did you follow the installation instructions?

 * [Sinatra Instructions](/getting_set_up#sinatra)
 * [Grape Instructions](/getting_set_up#grape)


### Is the sockfile path writable?

By default, Skylight uses your Rails tmp path as the sockfile directory. In the event that this path isn’t writable you should set `daemon.sockdir_path` in your [config](/getting_set_up#setting-configuration-variables).


### Are you using NFS, possibly with Vagrant?

Skylight’s socket file can’t be located on an NFS mount. Set `daemon.sockdir_path` in your [config](/getting_set_up#setting-configuration-variables) to a non-NFS path.

>>>>>>> Add source markdown files to be parsed

### If you're running Unicorn, did you restart your master?

To make sure Skylight is activated, you may need to restart your Unicorn masters.

<<<<<<< 0664bf38bd973603f286c534e409d3e906ba9562
## The Skylight native extension wasn't found, but my platform claims to be supported.

To avoid taking your production application down due to an installation failure, Skylight does not raise an exception when it can't install the native agent. Currently, we support Linux 2.6.18+ and Mac OS X 10.8+. If you're running a compatible OS and still see errors, try running your applicaiton with `SKYLIGHT_REQUIRED=true`. This will cause Skylight to raise an exception when the native agent is missing. This exception may be useful in troubleshooting the problem. If you need help, send this to us at <support@skylight.io>.

## What if I need to load the Skylight gem before Rails?

Skylight performs setup when the gem is required, at which time Rails will be detected and tapped into. However,
you may find you have to manually require `skylight/railtie` if you need to load the Skylight gem before Rails.
=======

## The Skylight native extension wasn’t found, but my platform claims to be supported.

To avoid taking your production application down due to an installation failure, Skylight does not raise an exception when it can’t install the native agent. Currently, we support Linux 2.6.18+ and Mac OS X 10.8+. If you’re running a compatible OS and still see errors, try running your applicaiton with `SKYLIGHT_REQUIRED=true`. This will cause Skylight to raise an exception when the native agent is missing. This exception may be useful in troubleshooting the problem. If you need help, send this to us at [support@skylight.io](mailto:support@skylight.io).


## What if I need to load the Skylight gem before Rails?

Skylight performs setup when the gem is required, at which time Rails will be detected and tapped into. However, you may find you have to manually require `skylight/railtie` if you need to load the Skylight gem before Rails.
>>>>>>> Add source markdown files to be parsed
