# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "api_browser/version"

Gem::Specification.new do |s|
  s.name        = "api_browser"
  s.version     = ApiBrowser::VERSION
  s.authors     = ["Rune Botten"]
  s.email       = ["rbotten@gmail.com"]
  s.homepage    = "http://github.com/bengler/api_browser"
  s.summary     = "API doc engine"
  s.description = "API doc engine"

  s.rubyforge_project = "api_browser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "coderay", '1.0.6'
  s.add_dependency "yard"
  s.add_dependency "yajl-ruby"
  s.add_dependency "curb"
  s.add_dependency "yard-sinatra"
  s.add_dependency "oauth"
  s.add_dependency "activesupport"
  s.add_development_dependency "sinatra-contrib"

end
