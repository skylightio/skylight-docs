$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "skylight/docs/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "skylight-docs"
  s.version     = Skylight::Docs::VERSION
  s.authors     = ["Tilde"]
  s.email       = ["engineering@tilde.io"]
  s.homepage    = "http://skylight.io/support"
  s.summary     = "Skylight documentation"
  s.description = "Skylight documentation files"
  s.license     = "Creative Commons"

  s.files = Dir["{app,config,source,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.1"
  s.add_dependency "kramdown"
  s.add_dependency "sprockets-es6"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-livereload", '~> 2.5', '>= 2.5.2'
  s.add_development_dependency "rack-livereload"
end
