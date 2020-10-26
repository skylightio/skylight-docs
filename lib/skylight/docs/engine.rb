module Skylight
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Docs

      require 'kramdown'
      require 'kramdown-syntax-coderay'
      require 'sprockets/es6'

      configure do
        config.chapter_path = root.join('app/views/skylight/docs/chapters')
        config.user_features = nil
      end
    end
  end
end
