require 'nokogiri'

class QuickJump < Middleman::Extension

  attr_reader :target_selector, :destination_selector

  def initialize(app, opts={}, &blk)
    super

    @target_selector = opts[:target] || '.dw-article'
    @destination_selector = opts[:destination] || '.dw-sidenav'
  end

  def after_configuration
    quickjump = self

    app.after_render do |path, locs, template_class|
      content = self
      page = Nokogiri::HTML(content)
      target = page.css(quickjump.target_selector).first
      dest = page.css(quickjump.destination_selector).first

      if target && dest
        content = quickjump.process(page, target, dest)
      end

      content
    end
  end

  def process(page, target, dest)
    els = target.css('h2, h3, h4').sort

    els.each do |el|
      next unless %w(h2 h3 h4).include?(el.name)

      id = dasherize(el.text)

      el.remove_attribute 'id'
      el.add_child Nokogiri::HTML.fragment(%[<div id="#{id}" class="dw-nav-token"></div>])

      if el.name == 'h2'
        dest.add_child li(el.text, "##{id}")
      elsif el.name == 'h3'
        last = dest.css('li')[-1]
        sub  = last.children[-1]

        unless sub.name == 'ul'
          last.add_child Nokogiri::HTML.fragment(%[<ul class="nav"></ul>])
          sub = last.children[-1]
        end

        sub.add_child li(el.text, "##{id}")
      end
    end

    page.to_html
  end

  def li(text, url)
    Nokogiri::HTML.fragment %[<li><a href="#{url}">#{text}</a></li>]
  end

  def dasherize(txt)
    txt.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9_.-]/i, '')
  end

end

Middleman::Extensions.register(:quickjump, QuickJump)
