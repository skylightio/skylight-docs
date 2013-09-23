Sorry to hear you're having trouble. Below are some troubleshooting steps
you can try. If you're still having trouble, please contact us via e-mail
at [support@skylight.io](mailto:support@skylight.io).

### Skylight was working before, but now I'm only seeing "No requests in this time range" when viewing an app.

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

### How do I use Skylight if my app is hosted on Heroku?

We are working on a Heroku add-on that will make this super-easy. But,
if you're deployed on Heroku, there's just one command you need to run
to make your Skylight API token available:

    heroku config:set SKYLIGHT_AUTHENTICATION="<token>"

Note that changing a config var in Heroku will cause your application to
restart. Once the app has restarted and handled several requests, you
should begin seeing performance data about your application in Skylight.

For more information about setting Heroku config vars, see
[Configuration and Config Vars](https://devcenter.heroku.com/articles/config-vars)
in the Heroku documentation.

### I'm using Heroku but no data is showing up in Skylight.

First, make sure that there is traffic to your application. If your
Rails app is handling requests, you should start to see data in Skylight
in just a few minutes.

If your app is running and has traffic, but you're still not seeing
anything in Skylight, verify that the `skylight` gem is installed and
running properly.

Make sure you are using the latest version of the Skylight gem (0.1.8
when this was written). In the directory for your Rails app, run this
command:

    bundle list | grep skylight 

You should see something like the following output:

    * skylight (0.1.8)

If the gem is installed and up-to-date, the next step is to verify that
it is running correctly:

1. In one terminal window, run `heroku logs -t` to show the application
   log.
2. In another terminal window, run `heroku restart` to restart the app.

Keep an eye on the log terminal. If you see an error message stating
that the Skylight agent is missing an authentication token, make sure
that your auth token is set by running:

    heroku config:set SKYLIGHT_AUTHENTICATION="<your token>"

### I deployed my application, but no data is appearing in Skylight.

Ensure that the application is running with the correct Rails
environment. By default, the agent only starts in the **production**
environment, but this can be configured.
