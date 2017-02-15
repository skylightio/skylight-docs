module Skylight
  module Docs
    module ApplicationHelper
      def is_current_chapter?(id)
        request.path == chapter_path(id)
      end
    end
  end
end
