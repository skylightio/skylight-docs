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
  s.licenses     = ["CC BY-NC-SA 4.0", "MIT"]

  s.files = Dir["{app,config,source,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 7.0.0"
  s.add_dependency "kramdown", "~> 2"
  s.add_dependency "kramdown-parser-gfm"
  s.add_dependency "kramdown-syntax-coderay"
  s.add_dependency "sprockets-es6"
end
