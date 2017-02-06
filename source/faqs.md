---
title: FAQs
description: You guessed it - frequently asked questions!
order: 8
updated: January 1, 2017
---

## App Management

### How do I share my app with others?

Anyone with access to an app can grant access to others. You can do this on your application-specific settings page by adding the email address of the invitee.

![adding collaborators](../assets/adding-collaborators.png)

Note that invites are currently app-specific only. If you want to grant access to multiple apps, repeat the step above on the settings page of each app.

The user will receive an invite via email. If they don't yet have a Skylight account, that email invite will include a link to sign up. Once they complete the steps, they'll see the app inside their account.

You can add unlimited users/collaborators to your app.


### How can I transfer an app to another account?

Just contact us via the in-app messenger to request a transfer.


### How can I delete an app?

Only app owners can delete apps. To do so, visit the settings page and find the app you'd like to delete listed in the left sidebar. Click on the app name to visit the settings page for that app. Scroll to the bottom of the page and click the link that says "Delete this application..."


### How can I remove myself from a shared app?

A shared app is simply an app you have access to but do not own. You can remove yourself from a shared app, if need be. This might be good if you have many shared apps and one of them is no longer relevant to you.

To remove yourself from an app, visit the settings page and find the app listed in the left sidebar. Click on the app name to visit the settings page for that app. Scroll to the bottom of the page and click the link that says "Remove myself from this application..."


## Feature Requests

### Can I get alerts when my performance changes?

While we don't yet give you up to the minute alerts, you can get insight into your app's weekly changes by signing up for the daily emails in your [account settings](https://www.skylight.io/app/settings/account). Down the road, we may add more immediate alerting when significant slowdowns occur in your app.


### Can I track deploys?

Soon! We've got work underway to make this happen. Sign up for our daily emails in your [account setting](https://www.skylight.io/app/settings/account) to get the latest scoop on development.


### Can I instrument background jobs like Sidekiq?

Background job instrumentation is a high priority for us. The technical aspect of it isn't too hard, but the big blocker is the UI. We don't just want to throw the background jobs into the regular UI since in most cases, they'll take much longer than normal requests and won't have the same immediate impact on the end-user.

But, we ourselves use Sidekiq and agree that it would be great to have more insight into our background jobs performance.


### Can I administer my apps with organizations?

Not yet, but it's something we've got on our roadmap. Our current thought it something based around Github organizations. If you've got any thoughts on this, we'd love to hear.


### Do you plan to add error tracking?

Right now we've chosen to focus on providing you the most useful performance information we can. That said, in the future we'd love to provide some basic notifications, especially around increased error rates. For more robust error tracking, we recommend a dedicated tool like Bugsnag.


### Do you have this feature that New Relic has?

New Relic has lots of features we don't have but, in our opinion, they're not all that useful. We've decided to focus on making sure that everything we show you provides immediate value. Our customers find that it's easier to make sense of our UI and to get _actionable_ information from it. Sure, we could throw more stats in, but sometimes less is more.


## I've got a different question.

We would love to hear your questions. Just shoot us an email at <support@skylight.io> or use the in-app messenger ("?" in the bottom right of the web UI). See our section on [Submitting Feedback](/contributing#reporting-bugs-and-submitting-feedback) for more details.
