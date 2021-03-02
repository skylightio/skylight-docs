---
title: App and Account Management
description: Add collaborators, manage your apps, and explore billing details.
---

## Account Management

### Changing your email address

#### GitHub-connected account

If you signed up with GitHub and don't have a password, your Skylight email address will automatically default to your GitHub email address. If you want to change it, first be sure the alternate email address has been added to your GitHub account. Then, head over to your <%= link_to "account settings page", "/app/settings/account" %> and click the link to "Choose a different email address", located under your current email.

<%= image_tag "skylight/docs/app-and-account-management/github-change-email.gif", alt: 'Changing an email address with a GitHub-connected account', style: img_width(600) %>

#### Email-connected account

If you have an email and password (even if your account is also connected to GitHub), you can change your email address on your <%= link_to "account settings page", "/app/settings/account", alt: 'Changing an email address with an email-connected account', style: img_width(600) %>.

<%= image_tag "skylight/docs/app-and-account-management/change-email.gif" %>

### Changing your password

If you signed up for Skylight with an email and password, you can change your password on the <%= link_to "password settings page", "/app/settings/account/password" %>.

<%= image_tag "skylight/docs/app-and-account-management/change-password.gif",  alt: 'Changing a password', style: img_width(500) %>

### Cancelling your account

We're sorry to see you go! If you wish to cancel your account, we recommend that you first remove the Skylight gem from your apps to prevent any further charges. Then, visit your <%= link_to "account settings page", "/app/settings/account" %>, scroll to the bottom, and click "Cancel your account...". Follow the instructions in the modal to pay any remaining balance and cancel your account.

## App Management

### App ownership

Currently, only one single Skylight user can retain ownership of an app. The owner of an app is responsible for managing payments and credit card information, has access to an app's billing history, and can also rename and delete an app.

<%= render layout: 'note', locals: { type: 'note' } do %>
  You can transfer app ownership to another Skylight user by contacting us via the in-app messenger.
<% end %>

### Sharing an app with others

If you're the app owner, you can share an app with multiple people at once on your app's settings page <%= link_to "using GitHub", "#add-multiple-users-through-github" %>. Anyone with access to the app can add new collaborators using <%= link_to "email addresses", "#add-users-by-email" %>, also on your app's settings page. You can add unlimited users/collaborators to your app.

Note that invites are currently app-specific only. If you want to grant access to multiple apps, repeat the steps below on the settings page of each app.

#### Add multiple users through GitHub

Chances are, the people who need access to an app on Skylight will be the same people working on that app and pushing code to GitHub. With Skylight's GitHub integration you can give access to all those people in just a few clicks!

You can read more in the <%= link_to "announcement blog post", "http://blog.skylight.io/i-feel-a-connection-a-github-connection/" %> and our <%= link_to "blog post detailing its development", "http://blog.skylight.io/connecting-skylight-apps-to-github-the-devil-is-in-the-details/" %>.

<%= image_tag 'skylight/docs/app-and-account-management/github-add-repo-1.png', alt: 'The "connect repo" button', style: img_width(500) %>

<%= image_tag 'skylight/docs/app-and-account-management/github-add-repo-2.png', alt: 'Options for connecting your repo', style: img_width(500) %>

If you are the owner of the app on Skylight and logged in via GitHub, navigate to your app's settings page.

1. Click on the field marked "Search or select an organization" and choose the organization that owns the app you're looking for (it must be an organization repo).
1. Click on the field marked "Search or select a repository" and choose the repo you wish to connect to GitHub.
1. Select your desired privacy settings. You can choose to give access to admin users only, or to all GitHub users with access to the repo.
1. Click "Connect" and you're done!

Once your Skylight app is connected to a GitHub repo, anyone with access to that repo can just log into Skylight with GitHub, and they will be automatically connected! Easy!

##### Removing or changing a repo already connected to a Skylight app

It's pretty similar to the process for adding a repo to an app:

<%= image_tag "skylight/docs/app-and-account-management/github-remove-repo.png", style: img_width(500) %>

1. Click on "disconnect." If you only want to remove the repo, you're done!
1. If you want to replace it with a different repo, just follow the steps above for adding a repo.

#### Add users by email

<%= image_tag 'skylight/docs/faqs/adding-collaborators.png', alt: 'adding collaborators', style: img_width(500) %>

The user you invite will receive an invitation via email. If they don't yet have a Skylight account, that email invite will include a link to sign up. Once they complete the steps, they'll see the app inside their account.


### Renaming an app

Only app owners can rename an app. To do so, visit your app's settings page, enter the new name into the "App name" field, and click on "Save changes".

<%= image_tag 'skylight/docs/app-and-account-management/renaming-an-app.png', alt: 'renaming an app', style: img_width(500) %>

### Adding an app url
Only app owners can add an app url. To do so, visit your app's settings page, enter your app's url into the "App url" field, and click on "Save changes". This will add a direct link to your app from your App Dashboard.

### Deleting an app

Only app owners can delete apps. To do so, visit the settings page and find the app you'd like to delete listed in the left sidebar. Click on the app name to visit the settings page for that app. Scroll to the bottom of the page and click the link that says "Delete this application..."

Deletions are permanent, so make absolutely sure you don't need the app anymore before deleting it!


### Removing yourself from a shared app

A shared app is simply an app you have access to but do not own. You can remove yourself from a shared app, if need be. This might be good if you have many shared apps and one of them is no longer relevant to you.

To remove yourself from an app, visit the settings page and find the app listed in the left sidebar. Click on the app name to visit the settings page for that app. Scroll to the bottom of the page and click the link that says "Remove myself from this application..."

## Billing

### Pricing

Skylight pricing is based on the total number of requests per month across all of the apps that you own. If you are a collaborator on a shared app (and not the owner), you will not be charged for that app's request usage. A **request** is considered to be any HTTP request that's handled by a Rails (or other framework's) server. Any SQL queries that are initiated as part of a request, for example, are considered to be part of that request and won't be counted separately.

Skylight is free up to the first 100,000 requests. After that, pricing starts at $20 per million requests handled, and continues according to the schedule on our <%= link_to "pricing page", "/pricing" %>. (The max tier is subject to a soft limit on the number of apps. Don't go too crazy!) As you can also see, the more you need, the lower your cost per million; built-in bulk discounting.

You can use <%= link_to "this calculator", "/pricing" %> to determine what your monthly price would be for a given request volume. Need more than 1 billion requests? <%= link_to "Contact us", "/contact" %> for volume pricing.

To be clear: no plans, nothing to choose. Skylight will automatically discount additional requests for you. We’re fond of simplicity.

### Annual Pricing

In some situations, you might wish to pay for Skylight on an annual basis. While our pricing is based on your total number of requests per _month_, we can accommodate requests for annual billing.

Currently, the best option we have for paying for Skylight on an annual basis is by pre-purchasing Skylight credits. We recommend that you pre-pay based on your estimated request usage, using our <%= link_to "pricing calculator", "/pricing" %>.

For example, if you estimate that your app(s) will have a monthly request count of 500,000 requests, then you would likely want to purchase a credit of $20 a month, for 12 months, which would amount to a grand total $240 of Skylight credits.

Once you have estimated your request usage and determined how many Skylight credits you'll likely need to pre-purchase, please contact us via the in-app messenger with the total amoufnt of Skylight credit you'd like to purchase. We will send you a custom invoice for the amount of Skylight credits you'd like to buy. Once we have received a payment from you, we'll add those credits into our system for the pre-paid amount.

<%= render layout: 'note', locals: { type: 'note' } do %>
  Pre-purchased Skylight credits are non-refundable and non-transferrable.
<% end %>

Each month, you will receive an invoice on your billing page that will indicate how many requests you used that month, as well as how many credits you have remaining. If you run out of credits, you will be billed monthly based on your usage from the prior month. You'll need to check these invoices every month to ensure that you have not run out of credits faster than expected, based on your request usage.

Of course, if you realize that you are running low on Skylight credits, then you can always "renew" them by prepaying for them again.

### Billing Details

The billing page gives you an overview of your current billing status.

<%= image_tag 'skylight/docs/getting_to_know_skylight/billing-graph.png', alt: 'Screenshot of current billing status' %>

At the top, we present the current billing period, including your total requests and price so far, along with a graph of your daily usage. Hovering over a specific bar in the usage chart will give you the specific number of requests each day.

Below that we show your current billing tier. See <%= link_to "the pricing page", "/pricing" %> for more information on tiers.

If you have multiple apps, we then show you how your usage breaks down across all of your apps.

<%= image_tag 'skylight/docs/getting_to_know_skylight/billing-apps.png', alt: "Screenshot of usage per app" %>

The UI does not currently support viewing historical usage. If you need details about past billing cycles, please contact us via the in-app messenger with your request.

### Referrals

Skylight users can earn rewards for referring their friends. We’ll give everyone you refer a $50 credit, and you’ll receive a $50 credit as soon as they become a paying customer. And yes, the $50 is in addition to the free 30 day trial they also get. Best of both worlds.

To refer a friend, head over to <%= link_to "your referrals page", "/app/settings/account/referrals" %> to retrieve your unique referral URL or send email invites directly through Skylight. You can also see a list of the people you've invited in the past.
