module Skylight
  module Docs
    module ApplicationHelper
      def is_current_chapter?(id)
        request.path == chapter_path(id)
      end

      def link_to(name=nil, options=nil, html_options=nil)
        if options.is_a?(String) && /^#/.match(options)
          # It's an anchor, so add the js-scroll-link class
          html_options ||= {}
          html_options[:class] ||= "js-scroll-link"
        end

        super(name, options, html_options)
      end

      def note_header(type)
        case type
        when 'pro_tip'
          'Pro Tip:'
        when 'important'
          'IMPORTANT:'
        else
          'Note:'
        end
      end

      def img_width(width)
        "width: 100%; max-width: #{width}px;"
      end
    end
  end
end
