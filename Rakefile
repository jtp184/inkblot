require "bundler/gem_tasks"
require 'cucumber'
require 'cucumber/rake/task'
require 'git'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty" # Any valid command line option can go here.
end

task :default => :features

task :docs do
  sh "rm -rf ./docs"
  rd_exclude = %w[bin tmp vendor/waveshare_epd coverage spec].map { |r| "--exclude=#{r}"}.join(' ')
  sh "rdoc --format=hanna --all --main=README.md #{rd_exclude}"
  sh "mv doc docs"
end

task :reinstall do
  sh "gem uninstall inkblot"
  Rake::Task["install"].invoke
end

task :bump do
  repo = Git.open(".")
  version_file = "./lib/inkblot/version.rb"
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

