require "skylight/docs/engine"

# creates an array of hashes containing the info from the frontmatter of each file.
# used to populate the tiles on the index page.
# example:
# [{ 'title' => 'title',
#    'description' => 'description',
#    'order' => '#',
#    'path' => '/support/dashified-file-name' }]
module Skylight
  module Docs
    class Chapter
      attr_accessor :description, :filename, :order, :title, :updated, :uri
      @@chapters = []

      # absolute path to the /markdown folder
      FOLDER = File.expand_path('../../../source', __FILE__)

      def initialize(filename)
        path = File.join(FOLDER, "#{filename}.md")
        raise "File Not Found: #{filename}" unless File.exist?(path)
        @filename = filename
        @file = File.read(path)

        @uri = "/support/#{filename}"

        @content = nil

        set_frontmatter
      end

      def self.all
        pattern = File.join(FOLDER, "**", "*.md")

        @@chapters = Dir[pattern].map do |path|
          Skylight::Docs::Chapter.new(File.basename(path, '.md'))
        end

        @@chapters.sort_by { |chapter| chapter.order }
      end

      def self.find(filename_to_find)
        @@chapters.find { |chapter| chapter.filename == filename_to_find }
      end

      def content
        # use Kramdown to parse a GitHub-flavored markdown (GFM) file to HTML
        @content ||= Kramdown::Document.new(clean_markdown, :input => 'GFM').to_html
      end

      private

        # sets frontmatter and validates that all required
        # frontmatter has been added
        def set_frontmatter
          valid_keys = ["title", "description", "order", "updated"]
          frontmatter = YAML.load(@file)

          valid_keys.each do |key|
            value = frontmatter[key]
            raise "Set frontmatter for `#{key}`" unless value
            instance_variable_set("@" + key, value)
          end
        end

        # gets the content of a file at a specified path with any frontmatter removed
        def clean_markdown
          frontmatter = get_frontmatter
          # if there is frontmatter, return everything but the frontmatter
          frontmatter ? frontmatter.post_match : @file
        end

        # gets a MatchData object representing the frontmatter from the file at the specified path
        def get_frontmatter
          frontmatter_regex = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m
          @file.match(frontmatter_regex)
        end
    end
  end
end
