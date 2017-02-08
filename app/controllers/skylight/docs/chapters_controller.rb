require_dependency "skylight/docs/application_controller"

module Skylight
  module Docs
    class ChaptersController < ApplicationController
      before_action :get_chapters

      def index
      end

      def show
        @chapter = Skylight::Docs::Chapter.find(params[:chapter])
        @current_path = request.path
      end

      private

      def get_chapters
        @chapters = Skylight::Docs::Chapter.all
      end
    end
  end
end
