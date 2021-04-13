---
title: Contributing
description: Improving the gem and reporting bugs.
---

## Reporting Bugs and Submitting Feedback

Filing bugs and submitting feedback from within Skylight is easy! Just click the floating Intercom button in the bottom right of the screen.

<%= image_tag 'skylight/docs/contributing/intercom-button.png', alt: 'intercom button', style: img_width(300) %>

This will bring up a pop-up with the history of your communication with us and a button for starting a new conversation.

<%= image_tag 'skylight/docs/contributing/intercom-messenger.png', alt: 'intercom messenger', style: img_width(300) %>

### Include Attachments

The conversation window also gives you the ability to submit attachments with your communication, if relevant. Just click the paperclip icon to the right of the conversation text field.


### Continuing the Conversation

In addition to being able to access your communications via the history, you'll be notified in two other ways:

* If a response has been sent, and you're in Skylight, the box will pop up again showing you your response (Alternatively, that box will pop up again next time you log in)
* You'll also receive a copy of any responses via email

Lastly, you can always email us at [support@skylight.io](mailto:support@skylight.io).


## We ♥️ Open Source

Sharing is caring when it comes to code. We're <%= link_to "proud to contribute", "http://www.tilde.io/about-us/#open-source" %> to some of the most innovative products in the industry. Additionally, our <%= link_to "Ruby agent", "https://github.com/skylightio/skylight-ruby" %> and <%= link_to "Phoenix agent", "https://github.com/skylightio/skylight-phoenix" %> are both open source, and we've spun off parts of our Rust code into the <%= link_to "Helix gem", "https://github.com/tildeio/helix" %> (read more about Helix in our <%= link_to "introduction blog post", "http://blog.skylight.io/introducing-helix/" %> and in our <%= link_to "followup", "http://blog.skylight.io/helix-one-year-later/" %>).

<%= link_to "Even these docs are open source!", "https://github.com/skylightio/skylight-docs" %> Feel free to make a PR with corrections or additional documentation.

### Code Contributions

If you want to try your hand at fixing bugs or adding features, our agent code is <%= link_to "publicly available on GitHub", "https://github.com/skylightio/skylight-ruby" %>. However, we do recommend that you contact us at [support@skylight.io](mailto:support@skylight.io) before getting started. We'd hate to have you spend time working on something that we might not be able to merge!

Also take a look at our <%= link_to "`CONTRIBUTING.md`", "https://github.com/skylightio/skylight-ruby/blob/master/CONTRIBUTING.md" %> and make sure to sign the CLA before you submit the PR.


#### Adding Instrumentation

If you're interested in adding instrumentation, make sure to check out our <%= link_to "overview of how it works", "./getting-more-from-skylight#how-skylight-works" %>. If the library in question doesn't have `ActiveSupport::Notifications` support, consider submitting a PR to them first to get it added. Once they have AS::N support, then we'd love to have you contribute a new Normalizer. If it's not feasible to get AS::N added to the library then go ahead and add a Probe for it. As always, don't hesitate to [contact us](mailto:support@skylight.io) if you have any questions.
