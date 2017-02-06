require "docs/engine"

module Skylight
  class Docs
    # absolute path to the /markdown folder
    FOLDER = File.expand_path('../../source', __FILE__)

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
        data_array << metadata if metadata['Order'].to_f > 0
      end
      # sort the array by Order, so they aren't just alphabetical
      data_array.sort_by { |hash| hash["Order"] }
    end

    # TODO: Refactor this method and use for search
    # generates a TOC for a given file
    def self.get_table_of_contents(filename)
      # TODO: We are parsing every .md file here. Could just parse the one that is current
      doc = Nokogiri::HTML(parse(filename))
      # use Nokogiri to get the children of the body element
      body = doc.at('body').children
      # concatenate a string of the Table of Contents headers formatted as we like
      create_toc_string(body, filename)
    end

    class << self
      private

      # creates a hash of metadata from the frontmatter
      def get_metadata(filename)
        path = File.join(FOLDER, "#{filename}.md")
        frontmatter = get_frontmatter(path)
        content_hash = {}

        if frontmatter
          frontmatter.to_s.lines.each do |line|
            parts = line.split(':')
            content_hash[parts.shift] = parts.join(':')
          end

          content_hash["Path"] = "/support/#{FormatHelpers.dashify(filename)}"
        end

        content_hash
      end

      # TODO: Refactor this method and use for search
      # loop through Nokogiri node array to put together linked chapter headers for ToC.
      # Returns a string of html.
      def create_toc_string(body, filename)
        chapter_titles = ''
        body.each do |element|
          anchor = FormatHelpers.anchorify(element.text)

          # using Rails link_to doesn't work here so we have to use HTML
          link = "<a href='#{FormatHelpers.filename_as_route(filename)}#{anchor}'>" +
                    "#{element.text}" +
                  "</a>"

          # TODO: Make the titles <h1>s, clean up css classes to include *'s etc
          # the only h2 is the title, which we already have
          unless element.name == "h2"
            # h3s are the first subheaders and don't get dashes
            if element.name == "h3"
              # we have classes in our Rails app for each h tag that simply indent
              # them a certain amount
              chapter_titles += "<li class='#{element.name}-indent'>" + link + "</li>"
            elsif element.name == "h5"
              chapter_titles += "<li class='#{element.name}-indent'>* " + link + "</li>"
            # everything that's not an h3 gets a dash, as per the design
            elsif element.name.match(/h\d/)
              chapter_titles += "<li class='#{element.name}-indent'>- " + link + "</li>"
            end
          end
        end
        # wrap the resulting ToC in a div with a class so we can style them
        "<div class='chapter-wrapper'>" + chapter_titles + "</div>"
      end
    end
  end

  class FormatHelpers
    def self.anchorify(text)
      # TODO: Check Kramdown for method that does this
      "##{text.downcase.tr(' ', '-').gsub(/[?!.;:]/, '')}"
    end

    def self.filename_as_route(filename)
      '/support/' + dashify(filename)
    end

    def self.dashify(filename)
      filename.tr('_', '-')
    end

    def self.undashify(filename)
      filename.tr('-', '_')
    end
  end
end
