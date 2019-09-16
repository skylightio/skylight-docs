class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action do
    # FIXME: remove this
    load Skylight::Docs::Engine.root.join("lib/skylight/docs/chapter.rb")
    true
  end

  around_action :capture_errs

  def capture_errs
    yield
  rescue => e
    # binding.pry
    raise
  end
end
