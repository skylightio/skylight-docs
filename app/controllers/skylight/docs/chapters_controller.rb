require_dependency "skylight/docs/application_controller"
require_dependency "skylight/docs/version"

module Skylight
  module Docs
    class ChaptersController < ApplicationController
      before_action :get_chapters

      def index
      end

      def show
        begin
          @chapter = Skylight::Docs::Chapter.find(params[:id])
        rescue Skylight::Docs::Chapter::ChapterNotFoundError
          flash[:error] = "Our docs have just received a makeover! \"#{params[:id].titleize}\" has been moved."
          redirect_to chapters_path
        end
      end

      private

      def get_chapters
        @chapters = Skylight::Docs::Chapter.all
      end
    end
  end
end
