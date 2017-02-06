require 'spec_helper'
require 'pry'
include TestHelper

describe 'Skylight::Docs' do
  describe '#parse' do
    it 'parses markdown to HTML elements' do
      TestHelper.expected_elements.each do |element|
        expect(Skylight::Docs.parse('markdown-styleguide')).to include(element)
      end
    end

    it 'returns an html message if the file does not exist' do
      expect(Skylight::Docs.parse('nothing')).to eq('<p>The file you are trying to parse does not exist.</p>')
    end
  end

  describe '#get_content' do
    let(:good_path) { File.expand_path('../../source/markdown-styleguide.md', __FILE__) }

    it 'returns the contents of a file as markdown' do
      expect(Skylight::Docs.get_content(good_path))
        .to include(TestHelper.some_expected_markdown_content)
    end

    it 'returns the contents of a file without front matter' do
      expect(Skylight::Docs.get_content(good_path))
        .not_to include(Skylight::Docs.get_frontmatter(good_path).to_s)
    end
  end

  describe '#get_markdown_files' do
    it 'returns an array of all available markdown files' do
      # figure out a better way to mock this statically
      # so we don't have to update this list every time a new file is added
      expected_filenames = ["contributing", "faqs", "get-to-know-skylight", "getting-set-up", "instrumentation", "markdown-styleguide", "performance-tips", "running-skylight", "troubleshooting"]
      expect(Skylight::Docs.get_markdown_filenames.sort).to eq(expected_filenames.sort)
    end

    it 'does not include non-markdown files' do
      expect(Skylight::Docs.get_markdown_filenames).not_to include('test-ruby-file')
    end
  end
end
