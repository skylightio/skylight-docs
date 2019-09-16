<%# TODO: fix `render` to accept a block, then modify all uses of this partial to accept a block. https://github.com/tildeio/direwolf-docs/issues/37 %>

<div class="interaction-bubble
            <%= 'interaction-bubble-perky' if local_assigns[:type] == 'pro_tip' %>
            <%= 'interaction-bubble-error' if type == 'important' %>
            ">
  <div class="interaction-bubble-text">
    <b>
      <%= 'Note:' unless type %>
      <%= 'Pro Tip:' if local_assigns[:type] == 'pro_tip' %>
      <%= 'IMPORTANT:' if type == 'important' %>
    </b>
    <%= note %>
  </div>
</div>
