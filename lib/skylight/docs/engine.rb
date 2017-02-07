module Skylight
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Docs

      require 'kramdown'
      require 'jquery-rails'
    end
  end
end
