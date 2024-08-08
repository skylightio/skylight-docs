module Skylight
  module Docs
    class Chapter
      attr_reader :id, :order

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
      def initialize(full_path)
        # /some/path/to/_00-foo-bar.md
        @full_path = full_path

        # _00-foo-bar.md
        @basename = File.basename(full_path)

        # 00-foo-bar
        @partial_path = File.basename(full_path, ".md").remove(/\A_/)

        order, @id = @partial_path.split('-', 2)
        @order = order.to_i
      end

      def to_partial_path
        partial_path
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
        [basename, Skylight::Docs::REVISION, ENV["SKYLIGHT_AGENT_EDGE_VERSION"]]
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
        attr_reader :full_path, :basename, :partial_path

        # Gets or sets the `file_content` read from the file at the Chapter's path.
        #
        # @return [String] the file's full content
        def file_content
          @file_content ||= File.read(full_path)
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
            YAML.load(file_content) || raise("No frontmatter found for #{basename}")
          end
        end

        # Gets a value from the frontmatter hash. Throws an error if the
        # value doesn't exist
        #
        # @return [String, Numeric] return value will vary
        def frontmatter_attr(key)
          frontmatter[key] || raise("Set frontmatter for `#{key}` in #{basename}")
        end
    end
  end
end
