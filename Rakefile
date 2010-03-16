require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'


desc 'Default: run unit tests.'
task :default => :test

desc 'Test Statelogic'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for Statelogic.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  files =['README.rdoc', 'CHANGELOG', 'MIT-LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "Statelogic Documentation"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers' << '--inline-source'
end

Rake::GemPackageTask.new(Gem::Specification.load('statelogic.gemspec')) do |p|
  p.need_tar = true
  p.need_zip = true
end

