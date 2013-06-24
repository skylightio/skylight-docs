require 'nokogiri'

class LinkCheck < Middleman::Extension
  def after_configuration
    this = self

    app.after_build do
      this.check_links(build_dir)
    end
  end

  class Checker
    def initialize(root)
      @root  = root
      @files = {}

      Dir["#{root}/**/*.html"].each do |file|
        relative = file.sub("#{root}/", "")
        @files[relative] = Nokogiri::HTML(File.read(file))
      end
    end

    def run
      success = true

      @files.each do |key, page|
        page.css("a").each do |a|
          href = a['href']

          next if href =~ /^https?:\/\//
          next if href =~ /^mailto:/

          path, fragment = href.split('#')

          path ||= ""
          fragment ||= ""

          if href.include?('#') && fragment == ''
            puts "[WARN] Empty fragment in link on #{key} (#{href})"
            success = false
          end

          if path == ""
            dest = page
          else
            path.gsub!(%r[/$], '')
            path += '/index.html' unless path =~ /\.html$/
            path.gsub!(%r[^/], '')

            unless dest = @files[path]
              puts "[WARN] Broken link on #{key} (#{href})"
              success = false
              next
            end
          end

          if fragment != ""
            target = dest.css("*[id=#{fragment}],a[name=#{fragment}]")

            if target.empty?
              puts "[WARN] Broken link fragment on #{key} (#{href})"
              success = false
            end
          end
        end
      end

      unless success
        abort
      end
    end
  end

  def check_links(root)
    Checker.new(root).run
  end

end

Middleman::Extensions.register(:link_check, LinkCheck)
