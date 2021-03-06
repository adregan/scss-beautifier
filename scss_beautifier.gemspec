# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scss_beautifier/version'

Gem::Specification.new do |spec|
  spec.name          = "scss_beautifier"
  spec.version       = SCSSBeautifier::VERSION
  spec.authors       = ["Ivan Tse", "Joe Natalzia"]
  spec.email         = ["ivan.tse1@gmail.com", "jnatalzia@gmail.com"]

  spec.summary       = %q{Beautify your SCSS code}
  spec.description   = %q{Transforms SCSS code to have consistent formatting}
  spec.homepage      = "https://github.com/paperlesspost/scss-beautifier"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sass", "~> 3.4"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"
end
