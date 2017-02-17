module Skylight
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Docs

      require 'kramdown'
      require 'sprockets/es6'
    end
  end
end
