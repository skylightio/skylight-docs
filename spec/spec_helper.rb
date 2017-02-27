require 'rails/all'
require 'pry'
require 'skylight/docs'
require 'kramdown'

RSpec.configure do |config|
  config.order = "random"
  config.color = true
end

Skylight::Docs::Chapter.const_set('FOLDER', File.expand_path('../test_source', __FILE__))

module TestHelper
  def expected_elements
    ['<table>', '</table>', '<td>', '<tr>', '<tbody>', '<thead>', '<h2 id="checklist-fun">',
      '</h3>', '<em>', '</em>', '<p>', '</p>', '<div class="language-yaml highlighter-coderay">', "<div class=\"language-ruby highlighter-coderay\">",
      '<li>', '</li>', '<pre>', '<del>', '</del>', '<a href=', '</a>', '<img ']
  end
end
