require 'spec_helper'
require 'pry'
include TestHelper

describe 'Skylight::Docs' do
  describe '#parse' do
    it 'parses markdown to HTML elements' do
      TestHelper.expected_elements.each do |element|
        expect(Skylight::Docs.parse('markdown_styleguide')).to include(element)
      end
    end

    it 'returns an html message if the file does not exist' do
      expect(Skylight::Docs.parse('nothing')).to eq('<p>The file you are trying to parse does not exist.</p>')
    end
  end

  describe '#get_content' do
    let(:good_path) { File.expand_path('../../source/markdown/markdown_styleguide.md', __FILE__) }

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
      expected_filenames = ["contributing", "faqs", "get_to_know_skylight", "getting_set_up", "instrumentation", "markdown_styleguide", "performance_tips", "running_skylight", "troubleshooting"]
      expect(Skylight::Docs.get_markdown_filenames.sort).to eq(expected_filenames.sort)
    end

    it 'does not include non-markdown files' do
      expect(Skylight::Docs.get_markdown_filenames).not_to include('test_ruby_file')
    end
  end

  describe '#get_table_of_contents' do
    it 'converts all headers in a markdown file to styled links' do
      expect(Skylight::Docs.get_table_of_contents('markdown_styleguide'))
        .to eq(TestHelper.table_of_contents)
    end
  end
end

describe 'Skylight::FormatHelpers' do
  describe '#anchorify' do
    it 'converts a sentence string into a dashified anchor' do
      expect(Skylight::FormatHelpers.anchorify('What can I do?')).to eq('#what-can-i-do')
    end

    it 'can convert sentences containing any punctuation' do
      expect(Skylight::FormatHelpers.anchorify('Hello! What about? THIS thing! Yes. Maybe;'))
        .to eq('#hello-what-about-this-thing-yes-maybe')
    end
  end

  describe '#dashify' do
    it 'converts an underscored string to a dashed string' do
      expect(Skylight::FormatHelpers.dashify('this_file_name')).to eq('this-file-name')
    end

    it 'does not change a one-word string' do
      expect(Skylight::FormatHelpers.dashify('word')).to eq('word')
    end
  end
end
