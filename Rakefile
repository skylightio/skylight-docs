begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Docs'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

DUMMY_APP_LOCATION = "dummy_app"
APP_RAKEFILE = File.expand_path("../#{DUMMY_APP_LOCATION}/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'


load 'rails/tasks/statistics.rake'



require 'bundler/gem_tasks'

def puts_in_pink(text)
  puts "\e[35m#{text}\e[0m"
end

desc "Sets up dependencies for engine and dummy app"
task :setup do
  puts_in_pink "Bundling in #{Dir.pwd}"
  sh "bundle install"
  puts_in_pink "Done bundling. Yay!"
end

desc "Sets up dependencies and runs the Rails server in the dummy app"
task :server => [:setup] do
  exec "bundle exec #{DUMMY_APP_LOCATION}/bin/rails server -p 3001"
end

desc "Runs the tests"
task :test do
  sh "rspec"
  Dir.chdir(DUMMY_APP_LOCATION) do
    sh "rspec"
  end
end

task default: :test
