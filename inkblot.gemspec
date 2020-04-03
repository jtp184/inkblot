require_relative 'lib/inkblot/version'

Gem::Specification.new do |spec|
  spec.name          = "inkblot"
  spec.version       = Inkblot::VERSION
  spec.authors       = ["Justin Piotroski"]
  spec.email         = ["jtp184@gmail.com"]

  spec.summary       = %q{Interface with Waveshare e-Paper hat}
  spec.homepage      = "http://justinp.io/"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.files += Dir['vendor/*']
  spec.files += Dir['vendor/waveshare_epd/*.py']

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry", "~> 0.12.2"
  spec.add_development_dependency "hirb", "~> 0.7.3"
  spec.add_development_dependency "awesome_print", "~> 1.8.0"
  spec.add_development_dependency "git", "~> 1.5.0"
  spec.add_development_dependency "cucumber", "~> 3.1.2"

  spec.add_dependency "mini_magick", "~> 4.10.1"
  spec.add_dependency "wkhtmltopdf-binary", "~> 0.12.5.4"
  spec.add_dependency "pdfkit", "~> 0.8.4.1"
  spec.add_dependency "imgkit", "~> 1.6.2"
end
