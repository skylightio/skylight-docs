source 'https://rubygems.org'

gemspec

group :test, :development do
  gem 'sprockets', '~> 3'
  gem 'pry-byebug'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'therubyracer' if ENV['CI_JOB_ID'] || ENV['GITHUB_ACTION']
end
