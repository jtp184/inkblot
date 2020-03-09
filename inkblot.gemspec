require_relative 'lib/inkblot/version'

Gem::Specification.new do |spec|
  spec.name          = "inkblot"
  spec.version       = Inkblot::VERSION
  spec.authors       = ["Justin Piotroski"]
  spec.email         = ["jpiotroski@appliedvr.io"]

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

  spec.add_development_dependency "pry"
  spec.add_development_dependency "hirb"
  spec.add_development_dependency "awesome_print"

  spec.add_dependency "mini_magick"
  spec.add_dependency "wkhtmltopdf-binary"
  spec.add_dependency "pdfkit"
  spec.add_dependency "imgkit"
end
