# Skylight Documentation

SETUP:
- run `bundle install` in both the root and `test/dummy` folders. The dummy app doesn't work great right now but we'll fix it before merging :P

## USAGE

Just mount the engine and you're good to go! In the Skylight Rails app, we have done it like so:

```
# in config/routes.rb

mount Docs::Engine, at: "/support", as: :support
```

## DEVELOPMENT

Build the gem by running `gem build docs.gemspec`. Add all new markdown files to the `/source/markdown` folder. To see how they look, cd into `test/dummy`, run `rails s`, and navigate to `http://localhost:3000` to see the results! The dummy app is a bit broken at the moment but will be fixed up shortly.

If you are adding a new markdown file to the docs, the routes, index page links, and table of contents on each page are automatically generated for the dummy app based on what's in the `/markdown` folder, so no need to worry about that! Keep in mind that file names need to be the same as the chapter name which should also be the same text as the header on that page.

Be sure to include the following metadata in your markdown file:

```
---
title: This is the Title That Shows Up on the Support Index Page
description: This is what shows up on the index page as the description.
order: <put a number here>
updated: October 11, 2017
---
```

The order is important because that's the order each section appears on the index page, so keep that in mind!

Make sure the Table of Contents for whichever page you're working on still makes sense when you're done! It's generated based on header tags, so keep that in mind when writing.

If you want to see how various styles are parsed from markdown, check out the `/markdown_styleguide` path.

## TESTING

Run Rspec tests in the typical fashion - just enter `rspec` in the terminal from the `/docs` directory.
