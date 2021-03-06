# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vase/version"

Gem::Specification.new do |s|
  s.name        = "vase"
  s.version     = Vase::VERSION
  s.authors     = ["Krasimir Georgiev"]
  s.email       = ["void.unsigned@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{An algorithm visualization toolkit.}
  s.description = %q{An algorithm visualization toolkit.}

  s.rubyforge_project = "vase"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
