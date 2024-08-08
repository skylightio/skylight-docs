require "skylight/docs/engine"
require "skylight/docs/version"

module Skylight
  module Docs
    def self.user_features(context)
      if Engine.config.user_features.respond_to?(:call)
        Engine.config.user_features.call(context)
      end
    end
  end
end

require "skylight/docs/chapters"
require "skylight/docs/chapter"
