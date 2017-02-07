require_dependency "skylight/docs/application_controller"

module Skylight
  module Docs
    class ChaptersController < ::SmarketingController
      before_action :get_chapters

      def index
      end

      def show
        @chapter = Skylight::Docs::Chapter.parse(params[:chapter])
        @section_headers = Skylight::Docs::Chapter.get_markdown_filenames
        @current_path = request.path
      end

      private

      def get_chapters
        @chapters = Skylight::Docs::Chapter.get_metadata_array
      end
    end
  end
end
