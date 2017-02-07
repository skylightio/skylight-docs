require_dependency "docs/application_controller"

module Docs
  class ChaptersController < ::SmarketingController
    before_action :get_chapters

    def index
    end

    def show
      @chapter = Skylight::Docs.parse(params[:chapter])
      @section_headers = Skylight::Docs.get_markdown_filenames
      @current_path = request.path
    end

    private

    def get_chapters
      @chapters = Skylight::Docs.get_metadata_array
    end
  end
end
