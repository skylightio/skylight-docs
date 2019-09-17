require 'spec_helper'
include TestHelper

describe 'Skylight::Docs::Chapter' do
  let(:chapter) { Skylight::Docs::Chapter.new('01-markdown-styleguide') }
  let(:second_chapter) { Skylight::Docs::Chapter.new('02-a-aardvark-chapter') }
  let(:third_chapter) { Skylight::Docs::Chapter.new('03-third-chapter') }

  describe "initialize" do
    it "generates a filename, id, and order" do
      expect(chapter.filename).to eq('01-markdown-styleguide')
      expect(chapter.id).to eq('markdown-styleguide')
      expect(chapter.order).to eq(1)
    end
  end

  describe '#all' do
    it 'returns an array of all chapters' do
      # figure out a better way to mock this statically
      # so we don't have to update this list every time a new file is added
      expected_files = [chapter.filename, second_chapter.filename, third_chapter.filename]
      expect(Skylight::Docs::Chapter.all.map(&:filename).sort).to eq(expected_files)
    end

    it 'does not include non-markdown files' do
      expect(Skylight::Docs::Chapter.all.map(&:id)).not_to include('test-ruby-file')
    end
  end

  describe '#find' do
    it 'returns the correct Chapter object based on search parameters' do
      expect(Skylight::Docs::Chapter.find('markdown-styleguide').filename).to eq(chapter.filename)
    end

    it 'raises an error if the id is not found in /source' do
      id_to_find = "blep"
      expect { Skylight::Docs::Chapter.find(id_to_find) }
        .to raise_error(Skylight::Docs::Chapter::ChapterNotFoundError, "`#{id_to_find}` not found")
    end
  end

  describe '.<=>' do
    it "returns -1 if the first chapter's order is lower than the second" do
      expect(chapter <=> second_chapter).to eq(-1)
    end

    it "returns 1 if the first chapter's order is higher than the second" do
      expect(second_chapter <=> chapter).to eq(1)
    end
  end

  describe '.content' do
    # it 'parses `link_to` helpers, adding html options for external or anchor links' do
    #   expect(chapter.content.main).to include('<a target="_blank" rel="noopener noreferrer" href="http://www.example.com">external</a>')
    #   expect(chapter.content.main).to include('<a href="./a-aardvark-chapter">internal</a>')
    #   expect(chapter.content.main).to include('<a class="js-scroll-link" href="#header-1">anchor</a>')
    # end

    # it 'generates HTML for a table of contents' do
    #   expect(chapter.toc).not_to include('#header-1')
    #   expect(chapter.toc).to include('#header-2')
    #   expect(chapter.toc).to include('#header-3')
    #   expect(chapter.toc).not_to include('#header-4')
    # end

    # it 'does not include the frontmatter' do
    #   expect(chapter.content.main).not_to include(chapter.description)
    # end
  end

  describe '.description' do
    it 'returns the description of the chapter' do
      expect(chapter.description).to include('description')
    end

    describe 'with invalid frontmatter' do
      let(:invalid_chapter) do
        allow(Skylight::Docs::Chapter).to receive(:chapter_path) do
          Pathname.new(File.expand_path('../test_source_invalid_files', __FILE__))
        end

        Skylight::Docs::Chapter.new('01-chapter-without-frontmatter')
      end

      it 'throws an error if the description does not exist in the frontmatter' do
        expect { invalid_chapter.description }
          .to raise_error("Set frontmatter for `description` in #{invalid_chapter.filename}#{Skylight::Docs::Chapter::FILE_EXTENSION}")
      end

      it 'throws an error if there is no frontmatter for the chapter' do
        expect { invalid_chapter.description }
          .to raise_error("Set frontmatter for `description` in #{invalid_chapter.filename}#{Skylight::Docs::Chapter::FILE_EXTENSION}")
      end
    end
  end

  describe '.title' do
    it 'returns the title of the chapter' do
      expect(chapter.title).to eq('Markdown Styleguide')
    end

    it 'throws an error if the title does not exist in the frontmatter' do
      allow(Skylight::Docs::Chapter).to receive(:chapter_path) do
        Pathname.new(File.expand_path('../test_source_invalid_files', __FILE__))
      end

      invalid_chapter = Skylight::Docs::Chapter.new('01-chapter-without-frontmatter')
      expect { invalid_chapter.title }
        .to raise_error("Set frontmatter for `title` in #{invalid_chapter.filename}#{Skylight::Docs::Chapter::FILE_EXTENSION}")
    end
  end
end
