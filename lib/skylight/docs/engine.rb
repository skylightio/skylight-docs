module Skylight
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Docs

      require 'kramdown'
      require 'kramdown-syntax-coderay'

      configure do
        config.chapters_dir = root.join('app/views/skylight/docs/chapters')
        config.otel_chapters_dir = root.join('app/views/skylight/docs/otel_chapters')
        config.user_features = nil
      end
    end
  end
end
