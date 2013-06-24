module Helpers
  def thumbnail(src, opts={})
    <<-HTML
<div class="dw-thumbnail">
  <div class="thumbnail">
    #{image_tag src, opts}
  </div>
</div>
    HTML
  end
end
