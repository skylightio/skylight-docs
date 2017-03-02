# Skylight Documentation

## SETUP
`rake setup` will bundle install both the engine and dummy app dependencies.
`rake` or `rake server` will install dependencies and run the dummy app server on port 3001.
If you would like the browser to auto reload when you update your markdown files, after running the server, in a new terminal window, run `bundle exec guard`.

## USAGE

Just mount the engine and you're good to go! In the Skylight Rails app, we have done it like so:

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

### Adding New Markdown Files
Add all new markdown files to the `/source` folder. Use Github flavored markdown (though this gem doesn't yet support checklists). Filenames should be dasherized. Input all appropriate frontmatter following the pattern below.
The routes, index page links, and table of contents on each page are automatically generated based on what's in the `/source` folder, so no need to worry about that!
To see how they look, run `rake server` and navigate to `http://localhost:3001` to see the results!

Be sure to include the following frontmatter in your markdown file:

```
---
title: This is the Title That Shows Up on the Support Index Page and as the Header for the Chapter Page
description: This is what shows up on the index and chapter pages as the description.
updated: October 11, 2017 <This is a string of a date.>
---
```

Make sure the Table of Contents for whichever page you're working on still makes sense when you're done! It's generated based on header tags, so keep that in mind when writing.

### Markdown Rules
#### Links
Use `link_to`s for all links. We've implemented a custom `link_to` helper to maintain consistency of user experience. All external links (those starting with 'http') will be opened in a new tab. All anchor links will have the `.js-scroll-link` class added so that they get scroll-to functionality in the client app.
NOTE: We have not yet implemented &block functionality in the helper.

For example:
A link internal to `/support`:
`<%= link_to "support page", "./support-page" %>`
A link to another skylight.io page, not within support:
`<%= link_to "other Skylight page", "/smarket" %>`
A link to an external page:
`<%= link_to "blorgh", "http://www.blorgh.org" %>`

#### Partials
You can create partials to include in multiple chapters. Just create an `.md.erb` file in the `partials` folder with a filename beginning with an underscore (e.g. `_partial_name.md.erb`). You can then include this partial in chapters with:
`<%= render partial: "partial_name" %>`

### Renaming or Removing Chapters
If you rename or remove a chapter, make sure to update the redirect hash in `config/routes.rb`.

### Testing

Run Rspec tests in the typical fashion - just enter `rspec` in the terminal from the `/docs` directory.
