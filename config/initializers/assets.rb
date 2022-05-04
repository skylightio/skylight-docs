if Rails.application.config.respond_to?(:assets)
  Rails.application.config.assets.precompile += %w( skylight/docs/* )
end
