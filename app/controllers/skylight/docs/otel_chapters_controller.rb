require_dependency "skylight/docs/chapters_controller"
require_dependency "skylight/docs/application_controller"
require_dependency "skylight/docs/chapters"

module Skylight
  module Docs
    class OtelChaptersController < ChaptersController
      private

      def self.chapters_dir
        Skylight::Docs::Engine.config.otel_chapters_dir
      end

      def show_search?
        false
      end

      # Override the URL helpers so links work
      helper_method :chapter_path, :chapters_path

      def chapter_path(*)
        otel_chapter_path(*)
      end

      def chapters_path(*)
        otel_chapters_path(*)
      end
    end
  end
end
