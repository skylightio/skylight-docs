module Skylight
    module Docs
      class ChapterNotFoundError < ActionController::RoutingError
      end

      class Chapters
        # Given a pathname, find all the valid .md files in the directory
        def self.load(dir = Skylight::Docs::Engine.config.chapters_dir)
          pattern = dir.join("_[0-9]*.md")

          chapters = Dir[pattern].map do |path|
            Skylight::Docs::Chapter.new(path)
          end

          new(chapters)
        end

        def initialize(chapters)
          @chapters = chapters.sort_by(&:order)
        end

        def all
          @chapters
        end

        # Given an id, such as 'running-skylight', returns a particular
        # Chapter object from the @chapters array.
        #
        # @return [Chapter] the chapter
        def find(id)
          @chapters.find { |c| c.id == id } || raise(ChapterNotFoundError, "`#{id}` not found")
        end

        # The unique key to determine when to update the cache
        #
        # @return [Array<String>]
        def cache_key
          @chapters.flat_map { |c| c.cache_key }
        end
      end
    end
  end
