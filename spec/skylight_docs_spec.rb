require 'spec_helper'
require 'pry'
include TestHelper

describe 'Skylight::Docs::Chapter' do
  describe "initialize" do
    let(:chapter) { Skylight::Docs::Chapter.new('markdown-styleguide') }

    it 'raises an error if the file does not exist' do
      expect { Skylight::Docs::Chapter.new('nothing') }.to raise_error(StandardError, "File Not Found: nothing")
    end

    it 'gets the frontmatter and turns it into attributes' do
      expect(chapter.title).to eq('Markdown Styleguide')
      expect(chapter.description).to include('description')
      expect(chapter.order).to eq(0)
    end

    it 'stores the URI for the chapter' do
      expect(chapter.uri).to eq('/support/markdown-styleguide')
    end
  end

  describe '.content' do
    let(:chapter) { Skylight::Docs::Chapter.new('markdown-styleguide') }
    it 'parses markdown to HTML elements' do
      TestHelper.expected_elements.each do |element|
        expect(chapter.content).to include(element)
      end
    end

    it 'does not include the frontmatter' do
      expect(chapter.content).not_to include(chapter.description)
    end
  end

  describe '#get_markdown_files' do
    it 'returns an array of all available markdown files' do
      # figure out a better way to mock this statically
      # so we don't have to update this list every time a new file is added
      expected_filenames = ["contributing", "faqs", "get-to-know-skylight", "getting-set-up", "instrumentation", "markdown-styleguide", "performance-tips", "running-skylight", "troubleshooting"]
      expect(Skylight::Docs::Chapter.get_markdown_filenames.sort).to eq(expected_filenames.sort)
    end

    it 'does not include non-markdown files' do
      expect(Skylight::Docs::Chapter.get_markdown_filenames).not_to include('test-ruby-file')
    end
  end
end
