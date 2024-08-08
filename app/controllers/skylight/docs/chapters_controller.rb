require_dependency "skylight/docs/application_controller"
require_dependency "skylight/docs/chapters"

module Skylight
  module Docs
    class ChaptersController < ApplicationController
      rescue_from "Skylight::Docs::ChapterNotFoundError" do
        @id = params[:id]
        render :not_found, status: 404
      end

      def index
        chapters
      end

      def show
        @chapter = chapters.find(params[:id])
      end

      private

      def chapters
        @chapters ||= self.class.chapters
      end

      def self.chapters
        # Force reloading the chapters in development so that we don't
        # have to keep restarting the server when we make changes
        @chapters = nil if Rails.env.development?
        @chapters ||= Skylight::Docs::Chapters.load(chapters_dir)
      end

      def self.chapters_dir
        Skylight::Docs::Engine.config.chapters_dir
      end

      helper_method :show_search?

      def show_search?
        ENV['ALGOLIA_API_KEY'].present?
      end
    end
  end
end
