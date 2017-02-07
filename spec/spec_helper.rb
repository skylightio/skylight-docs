require 'rails/all'
require 'pry'
require 'skylight/docs'
require 'kramdown'

RSpec.configure do |config|
  config.order = "random"
  config.color = true
end

module TestHelper
  def expected_elements
    ['<table>', '</table>', '<td>', '<tr>', '<tbody>', '<thead>', '<h2 id="checklist-fun">',
      '</h3>', '<em>', '</em>', '<p>', '</p>', '<div class="language-yaml highlighter-coderay">', "<div class=\"language-ruby highlighter-coderay\">",
      '<li>', '</li>', '<pre>', '<del>', '</del>', '<a href=', '</a>']
  end

  def table_of_contents
    "<div class='chapter-wrapper'><li class='h1-indent'>- <a href='/support/markdown-styleguide#regular-markdown-section'>Regular Markdown Section</a></li><li class='h3-indent'><a href='/support/markdown-styleguide#test-for-h5'>Test for H5</a></li></div>"
  end
end
