module Skylight
  module Docs
    class Chapter
      class ChapterNotFoundError < ActionController::RoutingError
      end

      attr_accessor :id, :filename, :order

      # file extension of the source markdown files
      FILE_EXTENSION = '.md'

      # options to pass into the Kramdown document constructor
      KRAMDOWN_OPTIONS = {
        input: 'GFM', # Use GitHub-flavored markdown
        syntax_highlighter: :coderay,
        syntax_highlighter_opts: {
          css: :class, # use css classes instead of style attributes
          line_numbers: false
        },
        toc_levels: (2..3) # Generate TOC from <h2>s and <h3>s only
      }

      # found this Regex in the Jekyll repo, used to parse frontmatter
      # https://github.com/jekyll/jekyll/blob/27ed81547b12d28a60c51961b82a5723981feb7d/lib/jekyll/document.rb#L10
      FRONTMATTER_REGEX = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m

      # Creates an object containing content and metadata about a docs chapter.
      # Takes a filename (such as 'running-skylight') on initialization.
      def initialize(filename)
        @filename = filename.sub(/\A_/, '') # '00-dashified-file-name'

        number, @id = @filename.split('-', 2)
        @order = number.to_i
      end

      # Gets or sets a class variable @chapters, which is an array of
      # Chapter objects derived from the markdown folders in /source.
      # These chapters are sorted by their `order` attribute.
      #
      # @return [Array<Chapter>] all of the Chapter objects
      def self.all
        # Force reloading the chapters in development so that we don't
        # have to keep restarting the server when we make changes
        @chapters = nil if Rails.env.development?
        @chapters ||= begin
          # Match .md files in /source but not in /source/deprecated
          pattern = chapter_path.join("_[0-9]*#{FILE_EXTENSION}")

          Dir[pattern].map do |path|
            Skylight::Docs::Chapter.new(File.basename(path, FILE_EXTENSION))
          end
        end
      end

      def self.chapter_path
        Skylight::Docs::Engine.config.chapter_path
      end

      def to_partial_path
        filename
      end

      # Given a path, such as 'running-skylight', returns a particular
      # Chapter object from the @chapters array.
      #
      # @return [Chapter] the chapter
      def self.find(id_to_find, collection = all)
        collection.find { |c| c.id == id_to_find } || raise(ChapterNotFoundError, "`#{id_to_find}` not found")
      end

      # When sorting chapters, use their order for comparison
      #
      # @return [Boolean] whether or not the order is greater than, equal to, or less than the compared order
      def <=>(other)
        order <=> other.order
      end

      # The unique key to determine when to update the cache
      #
      # @return [Array<String>]
      def cache_key
        [filename, Skylight::Docs::REVISION, ENV["SKYLIGHT_AGENT_EDGE_VERSION"]]
      end

      # Gets or sets the `toc` of a Chapter object.
      # First, it gets the full contents of the file, minus the frontmatter.
      # Then, it parses markdown into html, splitting the table of contents off
      # from the main content.
      #
      # @return  String containing toc fragment for this chapter
      def toc
        @toc ||= begin
          split_token = "split_toc"

          # Add Kramdown Inline Attribute List to generate a table of contents,
          # followed by the split_token in a new paragraph
          raw_content = "* TOC \n {:toc .support-menu-detail-list #support-menu-detail} \n \n #{split_token} \n \n" + file_without_frontmatter
          # NOTE: this is no longer ERB-evaluated
          full_html = Kramdown::Document.new(raw_content, KRAMDOWN_OPTIONS).to_html
          toc, _ = full_html.split("<p>#{split_token}</p>", 2)

          toc
        end
      end

      # Gets the `description` from the Chapter's frontmatter.
      #
      # @return [String] the description
      def description
        frontmatter_attr("description")
      end

      # Gets the `title` from the Chapter's frontmatter.
      #
      # @return [String] the title
      def title
        frontmatter_attr("title")
      end

      # Gets `keep_secret` from the Chapter's frontmatter. Defaults to false
      # if not found in the frontmatter.
      #
      # @return [Boolean] whether the chapter is a secret chapter
      def keep_secret?
        frontmatter["keep_secret"]
      end

      # Whether the chapter should be shown on the index page and in other
      # chapters' TOCs.
      #
      # @return [Boolean] whether the chapter should be shown in the TOCs
      def show_in_index?(context = nil)
        return true unless keep_secret?

        if frontmatter["show_for"] && context
          Skylight::Docs.user_features(context).include?(frontmatter["show_for"])
        end
      end

      private
        # Gets or sets the `file_content` read from the file at the Chapter's path.
        #
        # @return [String] the file's full content
        def file_content
          @file_content ||= File.read(path)
        end

        # Gets the content of the Chapter's file minus its frontmatter.
        #
        # @return [String] the file content after the frontmatter
        def file_without_frontmatter
          frontmatter_match = file_content.match(FRONTMATTER_REGEX)
          # if there is frontmatter, return everything but the frontmatter
          frontmatter_match ? frontmatter_match.post_match : file_content
        end

        # Gets or sets the frontmatter attribute on the Chapter object. e.g.:
        # { 'title' => 'title',
        #   'description' => 'description',
        #   'order' => # }
        #
        # @return [Hash] see above
        def frontmatter
          @frontmatter ||= begin
            YAML.load(file_content) || raise("No frontmatter found for #{filename}#{FILE_EXTENSION}")
          end
        end

        # Gets a value from the frontmatter hash. Throws an error if the
        # value doesn't exist
        #
        # @return [String, Numeric] return value will vary
        def frontmatter_attr(key)
          frontmatter[key] || raise("Set frontmatter for `#{key}` in #{filename}#{FILE_EXTENSION}")
        end

        # Gets or sets the `path` attribute of the Chapter.
        #
        # @return [String] a string of the full path to the file
        def path
          @path ||= self.class.chapter_path.join("_#{filename}#{FILE_EXTENSION}")
        end
    end
  end
end
