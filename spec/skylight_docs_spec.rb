require 'spec_helper'
include TestHelper

describe 'Skylight::Docs::Chapters' do
  let(:chapters) { Skylight::Docs::Chapters.load }
  let(:invalid_chapters) { Skylight::Docs::Chapters.load Pathname.new(__dir__).join('test_source_invalid_files') }

  let(:chapter) { chapters.find('markdown-styleguide') }
  let(:second_chapter) { chapters.find('a-aardvark-chapter') }
  let(:third_chapter) { chapters.find('third-chapter') }

  describe "initialize" do
    it "generates a filename, id, and order" do
      expect(chapter.id).to eq('markdown-styleguide')
      expect(chapter.order).to eq(1)
    end
  end

  describe '#all' do
    it 'returns an array of all chapters' do
      # figure out a better way to mock this statically
      # so we don't have to update this list every time a new file is added
      expected_files = [chapter.id, second_chapter.id, third_chapter.id]
      expect(chapters.all.map(&:id)).to eq(expected_files)
    end

    it 'does not include non-markdown files' do
      expect(chapters.all.map(&:id)).not_to include('test-ruby-file')
    end
  end

  describe '#find' do
    it 'returns the correct Chapter object based on search parameters' do
      expect(chapters.find('markdown-styleguide')).to eq(chapter)
    end

    it 'raises an error if the id is not found in /source' do
      id_to_find = "blep"
      expect { chapters.find(id_to_find) }
        .to raise_error(Skylight::Docs::ChapterNotFoundError, "`#{id_to_find}` not found")
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


  describe '.description' do
    it 'returns the description of the chapter' do
      expect(chapter.description).to include('description')
    end

    describe 'with invalid frontmatter' do
      it 'throws an error if there is no frontmatter for the chapter' do
        expect { invalid_chapters.find('chapter-without-frontmatter').description }
          .to raise_error("Set frontmatter for `description` in _01-chapter-without-frontmatter.md")
      end

      it 'throws an error if the description does not exist in the frontmatter' do
        expect { invalid_chapters.find('chapter-with-missing-attributes').description }
          .to raise_error("Set frontmatter for `description` in _02-chapter-with-missing-attributes.md")
      end
    end
  end

  describe '.title' do
    it 'returns the title of the chapter' do
      expect(chapter.title).to eq('Markdown Styleguide')
    end

    describe 'with invalid frontmatter' do
      it 'throws an error if there is no frontmatter for the chapter' do
        expect { invalid_chapters.find('chapter-without-frontmatter').title }
          .to raise_error("Set frontmatter for `title` in _01-chapter-without-frontmatter.md")
      end

      it 'throws an error if the description does not exist in the frontmatter' do
        expect { invalid_chapters.find('chapter-with-missing-attributes').title }
          .to raise_error("Set frontmatter for `title` in _02-chapter-with-missing-attributes.md")
      end
    end
  end
end
