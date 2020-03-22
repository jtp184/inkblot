require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :docs do
  sh "rm -rf ./docs"
  sh "rdoc --format=hanna --all --main=README.md --exclude=tmp"
  sh "mv doc docs"
end

task :reinstall do
  sh "gem uninstall inkblot"
  Rake::Task["install"].invoke
end

task :bump do
  repo = Git.open(".")
  version_file = "./lib/inkbot/version.rb"
  matcher = /VERSION = "(.*)"\.freeze/

  file_contents = File.read(version_file)

  updated = file_contents.gsub(matcher) do |v|
    v.gsub Regexp.last_match(1), Regexp.last_match(1).succ
  end

  File.open(version_file, "w+") { |f| f << updated }

  sh "bundle"

  repo.add(version_file)
  repo.add("Gemfile.lock")
end

