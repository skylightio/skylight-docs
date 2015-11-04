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

    nested = []
    last_chain = []

    # Chain ids to avoid duplicates
    els.each do |el|
      hash = {
        el: el,
        id: dasherize(el.text),
        children: []
      }

      parent = last_chain.last
      while parent && el.name <= parent[:el].name
        last_chain.pop
        parent = last_chain.last
      end

      if parent
        hash[:id] = "#{parent[:id]}-#{hash[:id]}"
        parent[:children] << hash
      else
        nested << hash
      end

      last_chain << hash
    end

    last_chain = []

    build_tree(dest, nested)

    page.to_html
  end

  def build_tree(dest, elements)
    elements.each do |hash|
      el = hash[:el]
      id = hash[:id]
      children = hash[:children]

      el.remove_attribute 'id'
      el.add_child Nokogiri::HTML.fragment(%[<div id="#{id}" class="dw-nav-token"></div>])

      list_item = dest.add_child(li(el.text, "##{id}")).first

      unless children.empty?
        child_list = list_item.add_child(Nokogiri::HTML.fragment(%[<ul class="nav"></ul>])).first
        build_tree(child_list, children)
      end
    end
  end

  def li(text, url)
    Nokogiri::HTML.fragment %[<li><a href="#{url}">#{text}</a></li>]
  end

  def dasherize(txt)
    txt.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9_.-]/i, '')
  end

end

Middleman::Extensions.register(:quickjump, QuickJump)
