---
title: Performance Tips
description: Tips for fixing common problems you might encounter in your application.
---

## Ship First, Optimize Later

Like many others in the Ruby community, we value developer productivity and writing beautiful, maintainable code. Of course it's important to be mindful of performance when <%= link_to "writing framework code", "https://github.com/rails/rails/pull/21057" %>. That said, when it comes to working on our apps, we'd rather spend our precious time (and brain cycles!) shipping new features. Hoisting variables and tearing apart nested loops is fun and all, but not the _best_ use of time if we can help you avoid it.

With Skylight, you can rest easy knowing that we'll give you a <%= link_to "heads up", "./skylight-guides#heads-up" %> on any potential performance problems. That way, you can focus your limited time in the places where it matters to you the most.

## Repeated Queries

In general, you will get better performance out of your database if you group together similar queries.

For example, let's say your application is making these queries:

```sql
SELECT * FROM "users" WHERE "id" = 12;
SELECT * FROM "users" WHERE "id" = 15;
SELECT * FROM "users" WHERE "id" = 27;
```

It would be more efficient to make a single SQL query:

```sql
SELECT * FROM "users" WHERE "id" IN (12, 15, 27);
```

Skylight automatically normalizes all three of the above repeated queries into the following query, allowing us to detect the repetition:

```sql
SELECT * FROM "users" WHERE "id" = ?;
```

### Identifying Repeated Queries

Skylight highlights endpoints and events that repeatedly make similar SQL queries with the database "heads up" icon:
<%= image_tag 'skylight/docs/features/heads-up-repeat-sql.png', alt: 'Screenshot of Repeat SQL icon' %>

### Possible Cause: N+1 Query

“N+1 Queries” are a very common cause of repeated queries in Rails applications. This happens when you make a request for a single row in one table, and then make an additional request per element in a `has_many` relationship.

Here’s an example offender (<%= link_to "from the Rails guides", "http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations" %>):

```ruby
def show
  client = Client.limit(10)
  @postcodes = client.map { |c| c.address.postcode }
end
```

The mistake here is that you’re making a single query for 10 clients, but then one query for each client to get its address, something like this:

```sql
SELECT * from "clients" LIMIT 10;
SELECT * from "addresses" WHERE "id" = 7;
SELECT * from "addresses" WHERE "id" = 8;
SELECT * from "addresses" WHERE "id" = 10;
SELECT * from "addresses" WHERE "id" = 12;
SELECT * from "addresses" WHERE "id" = 13;
SELECT * from "addresses" WHERE "id" = 15;
SELECT * from "addresses" WHERE "id" = 16;
SELECT * from "addresses" WHERE "id" = 17;
SELECT * from "addresses" WHERE "id" = 21;
```


#### The Solution

The solution to this problem is “eager loading”, which means specifying ahead of time which associations you will need.

```ruby
def show
  client = Client.includes(:address).limit(10)
  @postcodes = client.map { |c| c.address.postcode }
end
```

Now, Rails will generate the following SQL for you ahead of time, before you get to the `map`:

```sql
SELECT * from "clients" LIMIT 10;
SELECT * from "addresses" WHERE "client_id" IN (7, 8, 10, 12, 13, 15, 16, 17, 21);
```


### Other Possibilities

Skylight will report any kind of repeated query that includes more than four repetitions, happens on a regular basis, and consumes a large part of the total request.

This includes those involving `INSERT` statements. We tuned the heuristic for reporting the problems so that virtually all reported problems will benefit from grouping.

Not all repeated queries can be resolved using the “eager loading” technique described above, but because Skylight only reports repeated queries that consume a large part of the total request, your app will likely benefit from fixing it.


## Allocation Hogs

Your Rails app is probably humming along just fine most of the time. Still, your users probably have the occasionally painfully slow request seemingly at random. While unexplained slowdowns can happen for many reasons, the most common root cause is excessive object allocations.

### Garbage Collection Pauses

When you create objects in Ruby, they eventually need to be cleaned up. That cleanup (**garbage collection**, or GC) usually happens far away from the code that created the objects in the first place.

Even worse, it's not uncommon for the garbage collection to happen in a completely different request. Each request has a small chance of tipping the scales and triggering a GC run, resulting in seemingly random slowdowns for your users.

While this explains the mystery, it doesn't help resolve the problem. Fortunately, Skylight tracks object allocations throughout your requests, helping you zero in on parts of your app that are doing the most damage.

### Identifying Allocation Hogs

Endpoints with allocation hogs are identified in Skylight with the pie-chart "heads up":
<%= image_tag 'skylight/docs/features/heads-up-allocation-hog.png', alt: 'Screenshot of Allocation Hog icon' %>

By default, Skylight focuses on how much time your endpoints and events are taking. When you drill down into an endpoint, you will see a representative trace for that endpoint where the larger bars represent events that took a long time to complete. When you switch to **allocations mode**, the same trace will be re-scaled based on the number of allocations during each event, allowing you to quickly identify potentially problematic events (i.e. the largest bars in your traces).

<%= image_tag 'skylight/docs/features/allocations-mode.gif', alt: 'Animation of Allocations Mode transition' %>

### Fixing the Problem

Now that you've zeroed in on exactly which part of your app to work on, let's talk about the most effective ways to reduce allocations.

<%= render layout: 'note', locals: { type: 'pro_tip' } do %>
  Before you spend weeks applying the tips in this section to every line of code, here's a disclaimer: reducing allocations is a **micro-optimization**. This means that they produce very little benefit outside of hot paths and that they may reduce your future productivity (which may reduce your ability to do important macro-optimizations like caching). Be sure to use Skylight to identify allocation hot spots and focus your energy in those areas.
<% end %>

**What do we mean by hot paths? In short, loops.** A piece of code that produces 200 objects might be completely fine if called occasionally; but if you call that code thousands of times in a loop, it can really add up. This is even worse if you nest loops inside of other loops, where a small piece of code can inadvertently be run hundreds of thousands of times.

All of these might seem obvious, but in a high-level programming language like Ruby, it's very easy for loops (or even nested loops) to be hidden in plain sight.

Here's a simplified example we saw recently when using Skylight to identify memory hotspots in our own app:

```ruby
def sync_organization(organization)  
  Mixpanel.sync_organization(organization)

  organization.users.each do |user|
    Mixpanel.sync_user(user)
  end
end
```

At first glance, you can see that this code has a loop, but it looks pretty innocuous. However, the `sync_user` method calls into a 30-line method that contains many lines that look like this:

```ruby
user.apps.includes(:organization).map(&:organization)
```

Here, we are looping through each user in an organization, then looping through all the apps for each user. Now imagine that `sync_organization` itself is called multiple times in a single request. You can see how this can quickly add up.

This short line of code involves multiple **hidden loops**, allocating a large number of intermediate objects. When digging in to an allocation hot spot, the first step is to identify loops, and you should especially be on the lookout for these hidden loops, because they are very easy to miss.

Some examples of hidden loops:

* Methods on `Enumerable` or other collections, like `each` and `map` (especially when using `&:`, also known as the **pretzel operator**).
* Active Record associations and other relations (like `user.apps` in the example above, or calling `destroy_all` on a relation).
* APIs that work with files and other IO streams.
* APIs in other libraries, especially APIs that take collections and/or blocks.

Keep in mind that the problem is not the loop itself, but rather that the loop amplifies the effect of any repeated work. Therefore, there are two basic strategies to fixing the problem: _loop less_, or _do less work in each iteration of the loop_.

#### Iterate Less

One of the most common ways to reduce the number of iterations you do in Ruby is to use Active Record methods to combine work and take advantage of your database for the heavy-lifting.

For example, if you're trying to get a list of unique countries across all your users, you might be tempted to write something like this:

```ruby
User.all.map(&:country).uniq
```

This code fetches all the user records from your database, looping through them to create an Active Record object for each row. Next, it loops over all of them again to create a new array containing each country. Finally, it loops over this array to de-dupe the countries in Ruby.

As you can see, this approach ended up doing a lot of wasteful work, allocating many unnecessary intermediate objects along the way. Instead, you could make the database do the work for you:

```ruby
User.distinct.pluck(:country)
```

This generates a SQL query that looks like:

```SQL
SELECT DISTINCT "country" FROM "users";
```

Instead of making intermediate Ruby objects for every user and looping over those objects multiple times, this directly produces the array of countries in the database itself. This not only does less work in your application, but it also significantly reduces the work that your database has to do.

This technique works for updating and deleting too. Instead of iterating over the objects you want to change in Ruby:

```ruby
User.where("last_seen_at < ?", 1.year.ago).each(&:destroy)
```

You can do the same thing in the database directly:

```ruby
User.where("last_seen_at < ?", 1.year.ago).delete_all  
```

This generates a SQL query that looks like:

```SQL
DELETE FROM "users" WHERE last_seen_at < ...;
```

However, because the database is in charge of deleting the records, your Active Record validations and callbacks will not run, so you might not always be able to use this technique. This is also true about `update_all`.

If you find yourself looping over Active Record objects in Ruby, there is likely a way to shift some of the work to the database. The <%= link_to "Active Record Query Interface guide", "http://guides.rubyonrails.org/active_record_querying.html" %> is a good place to start.

Along the same lines, when looping through a large number of Active Record objects, consider using <%= link_to "batching APIs", "http://api.rubyonrails.org/classes/ActiveRecord/Batches.html" %> such as `find_each`. While they don't ultimately reduce the total number of allocations, they ensure that you are holding on to fewer objects at the same time, allowing the garbage collector to work more effectively.

#### Allocate Fewer Objects Per Iteration

If you have a loop in a hot path that absolutely must exist, you should try to find ways to allocate fewer objects inside each iteration of the loop.

The quickest wins here involve moving shared work outside of the loop and looking for seemingly benign constructs that need to allocate objects. Let's look at this hypothetical example:

```ruby
module Intercom  
  def self.sync_customers
    Intercom.customers.each do |customer|
      if customer.last_seen < 1.year.ago
        customer.deactivate!
      end

      if blacklisted?(domain: customer.email.domain)
        customer.blacklist!
      end

      log "Processed customer"
    end
  end

  def self.blacklisted?(options)
    ["hacked.com","l33t.com"].include?(options[:domain])
  end
end
```

In this seemingly simple example, there are multiple places where we are allocating unnecessary objects in each iteration:

* The call to `1.year.ago` creates multiple new objects in every iteration.
* The call to `blacklisted?` function allocates a hash (`{ domain: customer.email.domain }`).
* The call to `log` allocates a new copy of the string `"Processed customer"`.
* The method `blacklisted?` allocates an array (along with the strings inside it) every time it is called.

A slightly different version of this loop has many fewer allocations:

```ruby
module Intercom  
  def self.sync_customers
    inactivity_threshold = 1.year.ago

    Intercom.customers.each do |customer|
      if customer.last_seen < inactivity_threshold
        customer.deactivate!
      end

      if blacklisted?(domain: customer.email.domain)
        customer.blacklist!
      end

      log "Processed customer".freeze
    end
  end

  BLACKLIST = ["hacked.com","l33t.com"]

  def self.blacklisted?(domain:)
    BLACKLIST.include?(domain)
  end
end
```

Depending on how many customers this code is looping over, we might have saved a large number of allocations here:

* We hoisted `1.year.ago` outside the loop, so we allocate only one shared copy for the entire loop.
* We changed `blacklisted?` to take keyword arguments, which eliminates the need for the hash since Ruby 2.2.
* We moved the blacklist array to a constant, so it is shared across calls.
* We used `"string".freeze`, which guarantees that a single string will be created and reused since Ruby 2.1.

The last point deserves a special mention: by guaranteeing the immutability of your string literals, Ruby can reuse the same instance of the string object across multiple calls. This essentially allows Ruby to hoist the string for you (similar to how we moved the blacklist into a constant) while keeping the string inline for readability.

The `freeze` call introduced some visual noise here, but this might soon be a thing of the past. <%= link_to "Matz", "https://en.wikipedia.org/wiki/Yukihiro_Matsumoto" %> has announced long term plans to make this the default behavior. Regular expressions, integers (`Fixnum`s), and most floating point values already receive similar optimizations in modern Rubies, so you normally wouldn't have to worry about hoisting them manually either.


## Expensive Views

One of the easiest ways to get a decent performance boost out of a Rails app is to find ways to cache expensive HTML or JSON fragments.

### Identifying Expensive Views

To get the best bang for your buck, you should focus your energy on areas of your templates that are doing the most work. Using Skylight, you can look at your endpoint's Event Sequence to get a sense of which templates to focus on. In this example, the bulk of the time is actually spent in just one HTML fragment:

<%= image_tag 'skylight/docs/performance_tips/expensive-view.png', alt: 'Screenshot of an expensive view' %>

Additionally, the bulk of the allocations for this endpoint occur within the same HTML fragment:

<%= image_tag 'skylight/docs/performance_tips/expensive-view-allocations.png', alt: 'Screenshot of an expensive view in allocations mode' %>

Adding caching to this template will improve time spent for this endpoint _and_ reduce <%= link_to "garbage collection pauses", "#garbage-collection-pauses" %> across the application.

### Use Basic Fragment Caching

Looking into `index.html.erb`, we find a few truly dynamic bits, like this:

```erb
<%%= render partial: 'shared/flash',  
    locals: { flash: flash, class_name: "banner" } %>
```

But for the most part, it's a large template whose dynamic bits look like this:

```erb
<%%= link_to "Sign Up For Free", signup_path, class: 'signup' %>
```

Fortunately, **Rails makes caching really easy!** Just wrap the area of the template that you want to cache with a cache block:

```erb
<%% cache(action_suffix: "primary") do %>  
<section class="hero">  
  <div class="container">
    ...
  </div>
</section>

<section class="data">  
  <div class="container">
    ...
  </div>
</section>  
<%% end %>
```

When using fragment caching, remember three things:

1. **Pick a key that describes the fragment you are caching.** You can use `action_suffix`, as in this example, if the key is unique only inside of this action. (You can also <%= link_to "use an Active Record object as your cache key", "http://apidock.com/rails/ActiveRecord/Integration/cache_key" %>, which is quite convenient and simple in the right situations.)
1. **The easiest caching backend is memcached.** This is because <%= link_to "memcached", "http://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-memcachestore" %> automatically expires keys that haven't been used in a while (an "LRU" or "least recently used" expiration strategy), and cache expiration is the hardest part of a good caching strategy.
1. **Focus on the big spenders.** It's tempting to spend a lot of time caching all of your HTML and trying to identify good cache keys for everything. In practice, you can get big wins by just caching expensive fragments that have easy cache keys (either because the template is relatively static, or because they're derived from an Active Record object, which has built-in caching support).


## Synchronous HTTP Requests

When you’re just starting out, it’s too easy to make synchronous HTTP requests inside your requests, because why not? Getting a worker setup up and running takes time and it adds operational cost to your app while you're still trying to get it off the ground (usually with a tiny team).

Once you get going though, synchronous HTTP requests are one of the biggest culprits when it comes to slow requests. It's also easy to lose track of them because you're likely synchronizing with third party services in `before_filter`s or middlewares, two areas of code you don't look at very often.

### Identifying Slow Synchronous HTTP Requests

When using Skylight, be on the lookout for grey boxes indicating synchronous HTTP requests:

<%= image_tag 'skylight/docs/performance_tips/synchronous-http-request.png', alt: 'Screenshot of an synchronous http request' %>

In most cases, you can collect quick wins by moving this work from your request/response cycle into a background worker.

### Move Third-Party Integration to Workers

Or, put another way: _do as little as possible in your request_.

One of the biggest things we did to improve the Skylight Rails app over time was to move third-party integrations (like updating Intercom or notifying Slack) from the request itself into a worker.

If you feel daunted by the process of getting background jobs up and running, don't! **It's one of the highest leverage improvements you can make to a Rails app.** Once you have the ability to send work to background jobs, you'll be surprised how often you use it.

If you're using Rails 4.2 or newer, <%= link_to "ActiveJob", "http://guides.rubyonrails.org/active_job_basics.html" %> makes the process even simpler. Rails now seamlessly bakes the notion of background jobs into the framework, complete with generators to get you started. We strongly recommend it.
