# Skylight Documentation

## SETUP
`rake setup` will bundle install both the engine and dummy app dependencies.
`rake` or `rake server` will install dependencies and run the dummy app server on port 3001.

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

### Javascript

In order to use the docs engine javascript (for TOC generation), add the following to your application.js:

```
//= require skylight/docs/application
```

## DEVELOPMENT

### Adding New Markdown Files
Add all new markdown files to the `/source` folder. Use Github flavored markdown (though this gem doesn't yet support checklists). Filenames should be dasherized. Input all appropriate frontmatter following the pattern below.
The routes, index page links, and table of contents on each page are automatically generated for the dummy app based on what's in the `/source` folder, so no need to worry about that!
To see how they look, run `rake server` and navigate to `http://localhost:3001` to see the results! The dummy app is a bit ugly at the moment but will be fixed up shortly.

Be sure to include the following frontmatter in your markdown file:

```
---
title: This is the Title That Shows Up on the Support Index Page and as the Header for the Chapter Page
description: This is what shows up on the index and chapter pages as the description.
order: <Put a number here indicating where the chapter should fit into the table of contents. Floats are OK.>
updated: October 11, 2017 <This is a string of a date.>
---
```

The order is important because that's the order each section appears on the index page, so keep that in mind!

Make sure the Table of Contents for whichever page you're working on still makes sense when you're done! It's generated based on header tags, so keep that in mind when writing.

### Markdown Rules
#### Links
If linking to a page within /support, use: `[check out this other support page](/support/other-page)`

If linking to an anchor on the same page, us: `[check out this section](#another-section){:class="js-scroll-link"}`

If linking to a page outside of the /support namespace, use: `[check out this blog](http://www.someones-blog.com){:target="_blank"}` or `[check out this page elsewhere on skylight.io](/pricing){:target="_blank"}`


### Testing

Run Rspec tests in the typical fashion - just enter `rspec` in the terminal from the `/docs` directory.
