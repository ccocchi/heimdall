lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "heimdall_apm/version"

Gem::Specification.new do |spec|
  spec.name          = "heimdall_apm"
  spec.version       = HeimdallApm::VERSION
  spec.authors       = ["Christopher Cocchi-Perrier"]
  spec.email         = ["cocchi.c@gmail.com"]
  spec.license       = 'LGPL-3.0'

  spec.summary       = "Open source monitoring for Rails applications"
  spec.homepage      = "https://github.com/ccocchi/heimdall"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.start_with?('test', 'bin', 'config')
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
