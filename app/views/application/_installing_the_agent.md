1. Visit the Skylight app to get your <%= link_to "setup token", "/app/setup" %>.

1. Add Skylight to _all_ environments in your Gemfile.
    ```ruby
    # Gemfile
    gem "skylight"
    ```

1. Run the following commands in your _development environment_:
   <!-- NOTE: This isn't actually ruby but the "shell" code formatting wasn't as nice -->
    ```ruby
    # Shell
    bundle install
    bundle exec skylight setup <setup token>
    ```
    This will automatically generate your <%= link_to "`config/skylight.yml`", "advanced-setup#agent-configuration" %> file.

1. <%= link_to "Deploy your application", "./advanced-setup#deployment" %> to production.

<%= render layout: "note", locals: { type: 'important' } do %>
  The contents of the skylight.yml file should be considered secret, so if your application is open source, you will not want to commit it to your repo. See <%= link_to "Setting Authentication Tokens", "./advanced-setup#setting-authentication-tokens" %> to learn how to set an environment variable instead.
<% end %>
