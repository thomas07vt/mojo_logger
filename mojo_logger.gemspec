# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mojo_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "mojo_logger"
  spec.version       = MojoLogger::VERSION
  spec.authors       = ["John Thomas"]
  spec.email         = ["john.thomas@autodesk.com"]

  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  #end

  spec.summary       = "log4j wrapper that handles logging in the Mojo framework."
  spec.description   = %q{ This gem is a wrapper around log4j that allow you to
  construct a log4j.properties file from a config block, rather than actually
  having a log4j.properties file. Useful for setting the log levels dynamically.
}
  spec.homepage      = "https://github.com/thomas07vt/mojo_logger/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
end
