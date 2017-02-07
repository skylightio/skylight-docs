module Skylight
  module Docs
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception
    end
  end
end
