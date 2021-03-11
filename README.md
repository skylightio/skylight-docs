# Skylight Documentation

## SETUP
`bundle install` as normal.
`rake server` will run the dummy app server on port 3001.
`rake [test]` will run the specs for both the engine and the dummy app.
If you would like the browser to auto reload when you update your markdown files, after running the server, in a new terminal window, run `bundle exec guard`.

## USAGE

We've already mounted the engine in the Skylight Rails app:

```
# in config/routes.rb

mount Skylight::Docs::Engine, at: "/support", as: :support
```

### Styles and layouts

In order to get the docs engine to use your application layout, override the Skylight::Docs::ApplicationController with the layout name.

```ruby
module Skylight
  module Docs
    class ApplicationController < ::ApplicationController
      layout "application"
    end
  end
end
```

## DEVELOPMENT

#### Previewing Local Changes (Tilde Employees Only)

To view changes locally, edit the `direwolf-client` gemfile to point to your local gem:

```
# Unset the current gem:
bundle config --delete local.skylight-docs && bundle

# Comment out the current gem
# gem "skylight-docs", git: "https://github.com/skylightio/skylight-docs",
#                      branch: "master"

# Uncomment the local gem:
gem 'skylight-docs', git: "https://github.com/tildeio/direwolf-docs",
                     branch: "enter-branch-name-here"

# Configure the local gem:
bundle config local.skylight-docs ../direwolf-docs && bundle

# Discard changes when finished.

```

### Adding New Markdown Files

Add all new markdown files to the `/views/skylight/docs/chapters` folder. Use GitHub flavored markdown (though this gem doesn't yet support checklists). Chapter filenames should be dasherized, and should start with an underscore and an integer that represents the chapter's position in the table of contents (e.g., `_50-my-middle-chapter.md`). Input all appropriate frontmatter following the pattern below.

The routes, index page links, and table of contents on each page are automatically generated based on what's in the `/chapters` folder, so no need to worry about that!

To see how they look, run `rake server` and navigate to `http://localhost:3001` to see the results!

Be sure to include the following frontmatter in your markdown file:

```
---
title: This is the Title That Shows Up on the Support Index Page and as the Header for the Chapter Page
description: This is what shows up on the index and chapter pages as the description.
---
```

Optionally, you can include `keep_secret: true` to hide the chapter in the chapter index page and TOCs for other chapters and to keep the chapter from being indexed by search engines.

Make sure the Table of Contents for whichever page you're working on still makes sense when you're done! It's generated based on header tags, so keep that in mind when writing. If you don't like the automatically generated id, you can specify one manually with `{#my-custom-id}`.

### Markdown Rules
#### Links
Use `link_to`s for all links. We've implemented a custom `link_to` helper to maintain consistency of user experience. All anchor links will have the `.js-scroll-link` class added so that they get scroll-to functionality in the client app.

For example:
A link internal to `/support`:
`<%= link_to "support page", "./support-page" %>`
A link to another skylight.io page, not within support:
`<%= link_to "other Skylight page", "/smarket" %>`
A link to an external page:
`<%= link_to "blorgh", "http://www.blorgh.org" %>`

#### Partials
You can create partials to include in multiple chapters. Just create an `.md` file in the `/views/application` folder with a filename beginning with an underscore (e.g. `_partial_name.md`). You can then include this partial in chapters with:
`<%= render partial: "partial_name" %>`

#### Fenced Code Blocks
Add the language for the fenced code block where possible. e.g.
~~~
```ruby
  # ruby code
```
~~~

For erb within a code block, add a second `%` to erb tags, e.g.
```
<%%= link_to "a thing", "www.example.com" %>
```

#### Note Callouts

Use the `note` partial to call attention to special information. There are three types of notes:

**Note:**
```
<%= render layout: "note" do %>
  Here are some notes. HTML, ERB, and markdown are OK here.
<% end %>
```

**Pro Tip:**
```
<%= render layout: "note", locals: { type: "pro_tip" } do %>
  Here's a tip from the pros.
<% end %>
```

**IMPORTANT:**
```
<%= render layout: "note", locals: { type: "important" } do %>
  This is important information.
<% end %>
```

### Renaming or Removing Chapters
If you rename or remove a chapter, make sure to update the redirect hash in `config/routes.rb`.

### Testing

There are rspec tests in ./spec and ./dummy_app/spec &mdash; run `rake test` from the root directory to run all tests.
