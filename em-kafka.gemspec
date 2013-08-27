# -*- mode: ruby; encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-kafka/version"

Gem::Specification.new do |s|
  s.name        = "em-kafka"
  s.version     = EventMachine::Kafka::VERSION
  s.authors     = ["Brandon Keene", "Evgeniy Dolzhenko", "Dimitrij Denissenko"]
  s.email       = ["bkeene@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{EventMachine Kafka driver}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "eventmachine-le"
  s.add_dependency "oj"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
end
