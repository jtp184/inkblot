require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'git'
require 'net/http'
require 'psych'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :docs do
  rd_exclude = %w[
    bin
    tmp
    vendor/waveshare_epd
    coverage
    spec
    wpa_supplicant.conf
  ].map { |r| "--exclude=#{r}" }.join(' ')

  sh "rdoc --output=docs --format=hanna --all --main=README.md #{rd_exclude}"
end

task :codepoints do
  codepoints_uri = 'https://raw.githubusercontent.com/google'
  codepoints_uri << '/material-design-icons/master/iconfont/codepoints'
  codepoints_uri = URI(codepoints_uri)

  codepoints = Net::HTTP.get(codepoints_uri)
                        .scan(/(\w+) (\w+)/)
                        .to_h
                        .transform_keys(&:to_sym)
                        .transform_values { |v| :"#x#{v.upcase}" }

  File.open('vendor/codepoints.yml', 'w+') { |f| f << Psych.dump(codepoints) }
end

task :reinstall do
  sh 'gem uninstall inkblot'
  Rake::Task['install'].invoke
end

task :bump do
  repo = Git.open('.')
  version_file = './lib/inkblot/version.rb'
  matcher = /VERSION = "(.*)"\.freeze/

  file_contents = File.read(version_file)

  updated = file_contents.gsub(matcher) do |v|
    v.gsub Regexp.last_match(1), Regexp.last_match(1).succ
  end

  File.open(version_file, 'w+') { |f| f << updated }

  sh 'bundle'

  repo.add(version_file)
  repo.add('Gemfile.lock')
end
