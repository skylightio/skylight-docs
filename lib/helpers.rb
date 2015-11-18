module Helpers
  def thumbnail(src, opts={})
    if opts[:retina]
      width = `sips -g pixelWidth src/img/#{src} | tail -n1 | cut -d" " -f4`
      max_width = width.to_i / 2;
      opts[:style] = ["width: 100%", "max-width: #{max_width}px", opts[:style]].compact.join('; ')
    end

    <<-HTML
<div class="dw-thumbnail">
  <div class="thumbnail">
    #{image_tag src, opts}
  </div>
</div>
    HTML
  end

  def page_subhead
    title = current_page.data.title
    if section = data.outline.find{|section| section.title == title }
      section.description
    end
  end

  def last_updated
    if date = current_page.data.last_updated
      content_tag(:small, "Last Updated: #{date.strftime("%b %d, %Y")}", class: "dw-last-updated")
    end
  end
end

