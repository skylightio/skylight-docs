---
title: Skylight for Open Source
description: Requirements, setup guides, and FAQs for the Skylight for Open Source Program.
---

## Requirements & Qualifications

### I have an open source app. Can I get a free Skylight account? {#requirements}

Yes! You can apply for a free [Skylight for Open Source][skylight-for-oss] account.

The goal of this program is to help encourage your contributors to find and address performance issues in your open source app, by giving them actionable insights and feedback with Skylight. To ensure we can be effective in achieving these goals, your app must meet the following requirements to qualify for the program:

- Its source code is publicly available on GitHub, and
- Its source code is licensed under an [open source license][oss-license], and
- It is accessible to anyone on the public Internet, and
- Its primary utility and the majority of its functionality is available for anyone to use for free, and
- It includes a link to its public Skylight dashboard in the README (if that is not feasible, the link can be included in an alternative prominent location that is easy for potential contributors to find, such as the site footer). The easiest way to do this is to add the performance badges to your README.

Here are some specific examples:

- [The Odin Project][odin] and the [Octobox][octobox] are both examples of _single-deployment_ apps that meet the requirements. Their source code is available on GitHub under an open source license. They are deployed as publicly accessible website available for anyone to use or sign up for free, other than any administration functionality.

- [Discourse][discourse] is an example of a _multi-deployment_ app. While its source code is available on GitHub under an open source license, it is up to the individual site operators to deploy their own installation of the app (either with the official managed hosting option or self-hosting).

  In this case, the purpose of the program is to help the site operators find performance issues in the underlying open source software (Discourse in this example), so that they can easily report problems to the maintainers or upstream any patches.

  The accessibility and purpose of the specific deployment will determine if it qualifies for the program. For example, [discuss.emberjs.com](https://discuss.emberjs.com) will qualify as it is publicly accessible and anyone can participate in the discussions on the forum.

  On the other hand, a private Discourse forum for your patrons will not qualify for the program at this time. Similarly, an [Errbit][errbit] instance or an open source Slack bot deployed for your company's internal use will also not qualify.

- Finally, an open source app that requires payment to access its features will generally not be accepted into the program at this time. Examples of this include blogs with paywalls, bitcoin exchanges and ICO websites. Companion websites for paid products, such as support websites or apps that are meant to used with a paid smartphone app, will also not qualify as they lose their primary utility without the paid product.

Skylight for Open Source is a new program that we're still experimenting with. We reserve the right to update or clarify these guidelines, make exceptions to them, or revoke access as the program evolves.

If you have any questions, please feel free to reach out at [support@skylight.io](mailto:support@skylight.io).

[skylight-for-oss]: https://www.skylight.io/oss
[oss-license]: https://opensource.org/licenses/alphabetical
[odin]: https://www.theodinproject.com/
[octobox]: https://octobox.io/
[discourse]: https://www.discourse.org/
[errbit]: https://github.com/errbit/errbit

## Setup Guide {#setup}

Once you have <%=link_to "applied", "https://www.skylight.io/oss#oss-sign-up"%> and been accepted to the Skylight For Open Source Program and created a Skylight account, the next step is to set up your app instance by creating your app <%= link_to "manually", "./advanced-setup#manual-app-creation" %>.

<%= render layout: "note", locals: { type: 'important' } do %>
The contents of the skylight.yml file should be considered secret, so be careful not to commit it to your repo! See <%= link_to "Setting Authentication Tokens", "./advanced-setup#setting-authentication-tokens" %> to learn how to set an environment variable instead.
<% end %>

After creating your app, you will need to connect your open source app's repository to Skylight using GitHub from <%= link_to "your app settings page", "/app/settings" %>. This will allow you to  grant access to your Skylight account to other maintainers of your open source app.

<%= render layout: "note", locals: { type: 'pro_tip' } do %>
  You can also invite contributors to your open source project to collaborate on your app's settings page. Please note that this will allow them to see application settings, such as the application's authentication token and the emails of other collaborators. It also will allow them to invite and remove collaborators themselves.
<% end %>

After your open source app is set up and reporting data, please [let us know](mailto:support@skylight.io) so that we can activate open source mode for you! In open source mode, you will see an open source badge, as well as a public link on your dashboard.

<%= image_tag 'skylight/docs/skylight-for-open-source/public-links.png', alt: 'Screenshot of open source public links in dashboard' %>

Both of these will link to your open source public dashboard, where your contributors can explore your public performance data. You can see examples of other open source apps' public dashboards at our <%= link_to "OSS site", "http://oss.skylight.io" %>.

On <%= link_to "your app settings page", "/app/settings" %>, you will find a place to add an app URL, which should be specific to your open source app.

<%= image_tag 'skylight/docs/skylight-for-open-source/app-url.png', alt: 'Screenshot of current billing status' %>

The app URL will add a direct link to your project's app, directly from the Skylight dashboard. This link will make it easy for contributors to your project to navigate between your public dashboard and your actual app.

Finally, you will need to include a link to your project's skylight dashboard within your app's README as part of the <%= link_to "program's requirements", "#requirements" %>. The easiest way to do this is to add our performance monitoring badge.

You can find the markdown for your app's GitHub badges on your app's settings page.

<%= image_tag 'skylight/docs/skylight-for-open-source/performance-badge.png', alt: 'Screenshot of performance badge on settings page', style: img_width(400) %>

For additional setup options, check out our documentation on <%= link_to "Advanced Setup", "./advanced-setup" %> and <%= link_to "Multiple Environments", "./environments" %>

## Program FAQs

### Are there pieces of customer information that will be available via my public Skylight dashboard? {#privacy}

Skylight works differently than other similar products, in that we rely heavily on aggregation, both for presenting useful data in the UI and also to keep our backend scalable. We don't keep parts of individual requests; the requests are essentially only used as "data points" to build statistical models about your app and its endpoints. For example, any SQL queries are parsed and sanitized on your server before they are sent to us. There is no way to get from the aggregated data back to an individual request.

Read more about <%= link_to "security and Skylight", "./faqs#will-my-users-private-data-be-sent-to-skylight" %>.

### Why did you create the Skylight for Open Source program? {#why}

Great question! We created the Skylight for Open Source program to make it easy for open source maintainers to share performance data with their contributors. You can read more about the Skylight for Open Source program and why it exists in our <%= link_to "announcement blog post", "http://blog.skylight.io/announcing-the-skylight-for-open-source-program/" %>.
