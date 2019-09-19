<% type ||= nil %>

<div class="interaction-bubble
            <%= 'interaction-bubble-perky' if type == 'pro_tip' %>
            <%= 'interaction-bubble-error' if type == 'important' %>
            ">
  <div markdown='1' class="interaction-bubble-text">
  **<%= note_header(type) %>**
  <% if local_assigns[:note] %>
    <%= note.html_safe %>
  <% else %>
    <%= yield %>
  <% end %>
  </div>
</div>
