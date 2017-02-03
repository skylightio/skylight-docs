$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "docs/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "docs"
  s.version     = Docs::VERSION
  s.authors     = ["Tilde"]
  s.email       = ["engineering@tilde.io"]
  s.homepage    = "http://skylight.io/support"
  s.summary     = "Skylight documentation"
  s.description = "Skylight documentation files"
  s.license     = "MIT"

  s.files = Dir["{app,config,source,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
  s.add_dependency "jquery-rails"
  s.add_dependency "kramdown"
end
