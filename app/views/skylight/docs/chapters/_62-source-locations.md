---
title: Source Locations
description: How does Skylight track source locations?
keep_secret: true
---

<%= render layout: "note" do %>
  The Source Locations feature is in alpha! Please <%= link_to "contact us", "/surveys/source-locations" %> to enable this feature for your user account.
<% end %>

## Welcome to the Source Locations Alpha!

Thank you for your interest in participating in the alpha test of Skylight's new Source Locations feature! We're excited to launch this new feature and appreciate your assistance in fine-tuning it. During the alpha phase, please submit feedback via our <%= link_to "contact form", "/contact" %>, or via the <%= link_to "in-app messenger", "./contributing#reporting-bugs-and-submitting-feedback" %>. Let us know how you are using the source locations feature to improve your app's performance!

The Source Locations feature is enabled per-user, so in order for the Skylight agent to collect and report source locations, your app must belong to an approved user account. If you have shared your app with additional collaborators, they will be able to view your app's source locations in the UI (but their own apps will not have the feature unless they join the alpha).

## Source Locations for Skylight

Skylight can help you pinpoint the locations in your code that correspond to events in the <%= link_to "Event Sequence", "./skylight-guides#event-sequence" %>. As Skylight traces your code it will report the file names and line numbers (for your <%= link_to "application code", "#application-code" %>) or gem names (for <%= link_to "external libraries", "#gem-code" %>). No more scouring your code trying to find out exactly where an expensive operation originated! As you browse your endpoint data, you will find these source locations in the detail card for each event:

<%= image_tag 'skylight/docs/features/source-locations-popover.png', alt: 'Screenshot showing detail card with source locations' %>

If your app is <%= link_to "connected to GitHub", "./app-and-account-management#add-multiple-users-through-github" %>, you can click the link to go directly to that line in your source code for the specified commit.

## What is a Source Location?

Skylight considers the 'source location' of an event to be the line in your code (or gem) that triggered the event. Because it would have significant performance costs to compute a complete call-stack for each event (and because that volume of data is usually unnecessary to provide answers), we instead locate the most relevant point of the call stack and report that as the source location.

### Application Code

For trace events that originate in your app, we collect the file path and line number as the source location (we consider in-project files to be those that live within `Rails.root` or the directory where your Gemfile lives). Consider the following controller action, where we load a set of monsters from an Active Record scope:

```ruby
  class MonstersController < ApplicationController
    def update
      monsters = Monster.active_at_night # <- The relation is built here

      monsters.each do |monster| # <- `SELECT * FROM monsters` is executed here
        monster.update(crepuscular: true)
      end

      render plain: :ok
    end
  end
```

The `active_at_night` scope (defined elsewhere) provides the logic needed to build the query, and the query is actually built on line 3 of the controller. However, since Active Record relations are lazy, and the query is not executed until data is accessed, the event is triggered on line 5 (in `monsters.each`), so that is what Skylight records as the source location for `SELECT FROM monsters`:

<%= image_tag 'skylight/docs/features/source-locations-popover-active-record.png', alt: 'Screenshot showing detail card with source location for Active Record' %>

### Gem Code

For trace events that originate in gems, we only report the gem name. For example, the Rails router comes from Action Pack, so we report that as the source location:

<%= image_tag 'skylight/docs/features/source-locations-popover-router.png', alt: 'Screenshot showing detail card with source location for Rails router' %>

### Synthetic Events

Occasionally you may see an event that does not have a source location, but instead says "source locations do not exist for synthetic events." Synthetic events are events that are added by Skylight for informational purposes, but that do not necessarily represent code that was traced during a request. Examples include garbage collection and the root event for Rack requests; because these do not correspond to specific application or library code, they do not have a source location.

## Change Detection

Skylight tracks changes across deploys for each source location. If the call site has moved between deploys (indicated by a yellow circle), we show the most recent location at the top with previous locations listed underneath.

<%= image_tag 'skylight/docs/features/source-locations-popover-change-detection.png', alt: 'Screenshot showing detail card with source locations change detection', style: img_width(700) %>

In the above example, the same SQL query was detected in three different locations for the first deploy, and only one location for the subsequent deploy. Note that the deploys (and corresponding source locations) that are displayed are dependent on the range you have selected in the <%= link_to "time explorer", "./features#time-explorer" %>.

<%= render partial: "note" do %>
  Change detection is subject to real-world conditions&mdash; if you have an infrequently-used call site, Skylight may not encounter it at all during the duration of a particular deploy, in which case it may appear to have been removed, only to come back in a future deploy. It also can not see changes to code other than file name and line number, so it is possible for a single 'source location' to point to two different methods across deploys (another reason to enable <%= link_to "deploy tracking", "#deploy-tracking" %>).
<% end %>

## Source Locations Configuration

### Enabling Source Locations

- `SKYLIGHT_SOURCE_LOCATIONS_ENABLED=true|false` (in env)
- `source_locations_enabled: true|false` (in skylight.yml)

The Source Locations feature is enabled by default in Skylight 5.0.0-beta2 and above. Before the Skylight agent will report Source Locations however, your friendly Skylight administrator (i.e., one of us) will need to enable source locations collection for your user account. Please fill out the <%= link_to "source locations alpha survey", "/surveys/source-locations" %> to be added to the alpha cohort.

If you need to disable source locations you can set one of the above config options to `false`. If you do so, please <%= link_to "get in touch with us", "/contact" %> and let us know why you needed to disable it.

### Deploy Tracking

Source Locations works best if you have enabled <%= link_to "deploy tracking", "./advanced-setup#deploy-tracking" %>, because it allows you find an event's source location for a particular moment in time, and track <%= link_to "changes across deploys", "#change-detection" %>

### Ignored Gems

Note that an event may sometimes be attributed to gem code that you did not expect (for example, a logger that wraps existing code). To avoid this you can add gem names as a comma separated list to `SKYLIGHT_SOURCE_LOCATION_IGNORED_GEMS` in your env, or `source_location_ignored_gems` in your skylight.yml file. By default, we ignore `skylight`, `activesupport`, and `activerecord`.

<%= render layout: "note", locals: { type: "important" } do %>
  Ensure you use the gem name and not the require path in case they are different, as is the case for all the Rails gems.
<% end %>
