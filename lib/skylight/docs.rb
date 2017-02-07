require "skylight/docs/engine"

module Skylight
  module Docs
    class Chapter
      attr_accessor :description, :order, :title, :updated, :uri

      # absolute path to the /markdown folder
      FOLDER = File.expand_path('../../../source', __FILE__)

      def initialize(filename)
        path = File.join(FOLDER, "#{filename}.md")
        raise "File Not Found: #{filename}" unless File.exist?(path)
        @file = File.read(path)

        @uri = "/support/#{filename}"

        @content = nil
        
        set_frontmatter
      end

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

      class << self
        # returns an array of all the filenames from the markdown folder w/o `.md`
        def get_markdown_filenames
          pattern = File.join(FOLDER, "**", "*.md")

          Dir[pattern].map do |path|
            File.basename(path, '.md')
          end
        end

        # creates an array of hashes containing the info from the frontmatter of each file.
        # used to populate the tiles on the index page.
        # example:
        # [{ 'title' => 'title',
        #    'description' => 'description',
        #    'order' => '#',
        #    'path' => '/support/dashified-file-name' }]
        def get_metadata_array
          data_array = []

          get_markdown_filenames.each do |filename|
            metadata = get_metadata(filename)
            # don't include files with an Order of 0 or less
            data_array << metadata if metadata["order"] > 0
          end
          # sort the array by Order, so they aren't just alphabetic
          data_array.sort_by { |hash| hash["order"] }
        end

        private

        # creates a hash of metadata from the frontmatter
        def get_metadata(filename)
          path = File.join(FOLDER, "#{filename}.md")
          content_hash = YAML.load(File.read(path))

          content_hash["Path"] = "/support/#{filename}" if content_hash

          content_hash
        end
      end

      def content
        # use Kramdown to parse a GitHub-flavored markdown (GFM) file to HTML
        @content ||= Kramdown::Document.new(clean_markdown, :input => 'GFM').to_html
      end

      private

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
