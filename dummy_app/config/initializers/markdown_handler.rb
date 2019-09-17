require "kramdown"

module MarkdownHandler
  def self.kramdown_options
    Skylight::Docs::Chapter::KRAMDOWN_OPTIONS
  end

  def self.frontmatter_regex
    Skylight::Docs::Chapter::FRONTMATTER_REGEX
  end

  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(view, source)
    source = source.sub(frontmatter_regex, "")
    compiled_source = erb.call(view, source)
    "Kramdown::Document.new(begin;#{compiled_source};end, #{kramdown_options}).to_html.html_safe"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
