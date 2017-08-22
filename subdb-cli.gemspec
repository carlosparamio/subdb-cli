# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'subdb/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "subdb-cli"
  spec.version       = Subdb::Cli::VERSION
  spec.authors       = ["Carlos Paramio"]
  spec.email         = ["hola@carlosparamio.com"]

  spec.summary       = %q{SubDB client in Ruby}
  spec.description   = %q{SubDB client in Ruby}
  spec.homepage      = "https://github.com/carlosparamio/subdb-cli"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.13.1"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
