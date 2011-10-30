# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "web-puppet/version"

Gem::Specification.new do |s|
  s.name        = "web-puppet"
  s.version     = WebPuppet::VERSION
  s.authors     = ["Gareth Rushgrove"]
  s.email       = ["gareth@morethanseven.net"]
  s.homepage    = "https://github.com/garethr/web-puppet"
  s.summary     = %q{Display Puppet node information as JSON over HTTP}
  s.description = %q{Daemon which serves information from a local puppet master as JSON over HTTP}

  s.rubyforge_project = "web-puppet"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "puppet", ">= 2.7.0"
end
