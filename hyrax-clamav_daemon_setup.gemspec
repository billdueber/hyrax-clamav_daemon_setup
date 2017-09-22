# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hyrax/clamav_daemon_setup/version"

Gem::Specification.new do |spec|
  spec.name          = "hyrax-clamav_daemon_setup"
  spec.version       = Hyrax::ClamavDaemonSetup::VERSION
  spec.authors       = ["Bill Dueber"]
  spec.email         = ["bill@dueber.com"]

  spec.summary       = %q{A rails generator to get ClamAV configuration for your Hyrax application}
  spec.description   = %q{
    In addition to being able to use the default Hyrax virus scanning (shelling
    out to ClamAV, have your application to use the `clamd`
    daemon or do no virus scanning at all, all configurable per Rails env.
  }
  spec.homepage      = "https://github.com/billdueber/clamav_daemon_setup"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"


end
