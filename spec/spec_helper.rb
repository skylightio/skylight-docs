ENV["RAILS_ENV"] = 'test'

require 'rails/all'
require 'pry'
require 'skylight/docs'
require 'kramdown'

RSpec.configure do |config|
  config.order = "random"
  config.color = true

  config.example_status_persistence_file_path = "tmp/test_status.txt"
end

Skylight::Docs::Engine.configure do
  config.chapters_dir = root.join("spec/test_source/skylight/docs/chapters")
end

module TestHelper
  def expected_elements
    ['<table>', '</table>', '<td>', '<tr>', '<tbody>', '<thead>', '<h2 id="header-2">',
      '</h3>', '<em>', '</em>', '<p>', '</p>', '<div class="language-yaml highlighter-coderay">', "<div class=\"language-ruby highlighter-coderay\">",
      '<li>', '</li>', '<pre>', '<del>', '</del>', '<a href=', '</a>', '<img ']
  end
end
