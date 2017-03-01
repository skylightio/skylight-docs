require "skylight/docs/engine"

module Skylight
  module Docs
    class Chapter
      class Content < Struct.new(:toc, :main)
      end

      class ChapterNotFoundError < ActionController::RoutingError
      end

      attr_accessor :id, :filename, :order

      # file extension of the source markdown files
      FILE_EXTENSION = '.md.erb'

      # absolute path to the /markdown folder
      if Rails.env.test?
        FOLDER = File.expand_path('../../../spec/test_source', __FILE__)
      else
        FOLDER = File.expand_path('../../../source', __FILE__)
      end

      # options to pass into the Kramdown document constructor
      KRAMDOWN_OPTIONS = {
        input: 'GFM',              # Use Github-flavored markdown
        coderay_css: :class,       # Output css classes to style
        toc_levels: (2..3),        # Generate TOC from <h2>s and <h3>s only
        syntax_highlighter_opts: {
          line_number_anchors: false  # Don't add anchors to line numbers
        }
      }

      # found this Regex in the Jekyll repo, used to parse frontmatter
      # https://github.com/jekyll/jekyll/blob/27ed81547b12d28a60c51961b82a5723981feb7d/lib/jekyll/document.rb#L10
      FRONTMATTER_REGEX = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m

      # Creates an object containing content and metadata about a docs chapter.
      # Takes a filename (such as 'running-skylight') on initialization.
      def initialize(filename)
        @filename = filename # '00-dashified-file-name'

        number, @id = filename.split('-', 2)
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
          pattern = File.join(FOLDER, "*#{FILE_EXTENSION}")

          Dir[pattern].map do |path|
            Skylight::Docs::Chapter.new(File.basename(path, FILE_EXTENSION))
          end
        end
      end

      # Given a path, such as 'running-skylight', returns a particular
      # Chapter object from the @chapters array.
      #
      # @return [Chapter] the chapter
      def self.find(id_to_find)
        all.find { |c| c.id == id_to_find } || raise(ChapterNotFoundError, "`#{id_to_find}` not found in #{FOLDER}")
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
        [filename, Skylight::Docs::REVISION]
      end

      # Gets or sets the `content` of a Chapter object.
      # First, it gets the full contents of the file, minus the frontmatter.
      # Then, it converts the ERB from the file to markdown.
      # Then, it parses markdown into html, splitting the table of contents off
      # from the main content.
      #
      # @return [Struct::Content] an object containing .toc and .main attributes
      def content
        @content ||= begin
          split_token = "split_toc"

          raw_content = ERB.new(file_without_frontmatter).result(binding)
          # Add Kramdown Inline Attribute List to generate a table of contents,
          # followed by the split_token in a new paragraph
          raw_content = "* TOC \n {:toc .support-menu-detail-list #support-menu-detail} \n \n #{split_token} \n \n" + raw_content

          full_html = Kramdown::Document.new(raw_content, KRAMDOWN_OPTIONS).to_html
          toc, main = full_html.split("<p>#{split_token}</p>", 2)

          Content.new(toc, main)
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

      # Gets the date last `updated` from the Chapter's frontmatter.
      #
      # @return [String] the date last updated
      def updated
        frontmatter_attr("updated")
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
        #   'order' => #,
        #   'updated' => 'date last updated' }
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

        # Wraps the image_tag helper so we can use it to parse .erb to .md
        # Adds .support-image and a generated unique class name to each image
        # for CSS selection
        #
        # @return [String] a string of html
        def image_tag(source, options={})
          dashified_filename = File.basename(source, ".*").gsub(/[\s_]/, '-')
          auto_class = "support-image support-image-#{dashified_filename}"

          if options[:class]
            options[:class] += " #{auto_class}"
          else
            options[:class] = auto_class
          end

          ActionController::Base.helpers.image_tag(source, options)
        end

        # Renders ERB partials, for example
        # `<%= render partial: "installing_the_agent" %>` will return the
        # contents of a file at partials/_installing_the_agent.md.erb
        #
        # @return [String] a string of markdown
        def render(partial:)
          path = "partials/_#{partial}#{FILE_EXTENSION}"
          file = File.read(File.join(FOLDER, path))
          ERB.new(file).result(binding)
        end

        # Gets or sets the `path` attribute of the Chapter.
        #
        # @return [String] a string of the full path to the file
        def path
          @path ||= File.join(FOLDER, "#{filename}#{FILE_EXTENSION}")
        end
    end
  end
end
