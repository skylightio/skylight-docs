require "skylight/docs/engine"

module Skylight
  module Docs
    class Chapter
      # absolute path to the /markdown folder
      FOLDER = File.expand_path('../../../source', __FILE__)

      # use Kramdown to parse a GitHub-flavored markdown (GFM) file to HTML
      def self.parse(filename)
        path = File.join(FOLDER, "#{filename}.md")
        if File.exist?(path)
          Kramdown::Document.new(get_content(path), :input => 'GFM').to_html
        else
          '<p>The file you are trying to parse does not exist.</p>'
        end
      end

      # returns an array of all the filenames from the markdown folder w/o `.md`
      def self.get_markdown_filenames
        pattern = File.join(FOLDER, "**", "*.md")

        Dir[pattern].map do |path|
          File.basename(path, '.md')
        end
      end

      # gets the content of a file at a specified path with any frontmatter removed
      def self.get_content(path)
        full_content = File.read(path)
        frontmatter = get_frontmatter(path)
        # if there is frontmatter, return everything but the frontmatter
        frontmatter ? frontmatter.post_match : full_content
      end

      # gets a MatchData object representing the frontmatter from the file at the specified path
      def self.get_frontmatter(path)
        content = File.read(path)
        frontmatter_regex = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m
        content.match(frontmatter_regex)
      end

      # creates an array of hashes containing the info from the frontmatter of each file.
      # used to populate the tiles on the index page.
      # example:
      # [{ 'Title' => 'title',
      #    'Description' => 'description',
      #    'Order' => '#',
      #    'Path' => '/support/dashified-file-name' }]
      def self.get_metadata_array
        data_array = []

        get_markdown_filenames.each do |filename|
          metadata = get_metadata(filename)
          # don't include files with an Order of 0 or less
          data_array << metadata if metadata['Order'] > 0
        end
        # sort the array by Order, so they aren't just alphabetical
        data_array.sort_by { |hash| hash["Order"] }
      end

      class << self
        private

        # creates a hash of metadata from the frontmatter
        def get_metadata(filename)
          path = File.join(FOLDER, "#{filename}.md")
          content_hash = YAML.load(File.open(path))

          content_hash["Path"] = "/support/#{filename}" if content_hash

          content_hash
        end
      end
    end
  end
end
