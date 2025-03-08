lib = File.expand_path('../solara/lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "solara/version"

Gem::Specification.new do |spec|
  spec.name        = 'solara'
  spec.version     = Solara::VERSION
  spec.authors     = ["Malek Kamel"]
  spec.email       = 'sha.kamel.eng@example.com'
  spec.summary     = "Solara is a Ruby library that simplifies the management of white label apps for Flutter, iOS, Android, and Web."
  spec.description = "Solara is a Ruby library that simplifies the management of white label apps for Flutter, iOS, Android, and Web. With a centralized dashboard and a powerful CLI, Solara enables effortless configuration and control over dynamic app components, streamlining the setup process for multiple brands."
  spec.homepage    = 'https://github.com/yourusername/solara'
  spec.license     = 'MIT'

  # Specify the required Ruby version
  spec.required_ruby_version = '>= 3.0.0'

  spec.files = Dir.glob("*/lib/**/*", File::FNM_DOTMATCH)
                .reject { |f| f.include?('lib/spec') } +
                Dir["bin/*"] +
                Dir["*/README.md"]

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = Dir["*/lib"]

  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'webrick', '~> 1.8.1'
  spec.add_dependency 'colorize', '~> 1.1.0'
  spec.add_dependency 'json-schema', '~> 4.3.1'
  spec.add_dependency 'xcodeproj', '~> 1.27.0'
  spec.add_dependency 'cgi', '~> 0.4.1'
  spec.add_dependency 'plist', '~> 3.7.1'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~>3.13.0"
end