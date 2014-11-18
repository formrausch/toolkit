$:.push File.expand_path("../lib", __FILE__)

require "viaduct/toolkit/version"

Gem::Specification.new do |s|
  s.name        = "viaduct-toolkit"
  s.version     = Viaduct::Toolkit::VERSION
  s.authors     = ["Adam Cooke"]
  s.email       = ["adam@viaduct.io"]
  s.homepage    = "http://viaduct.io"
  s.summary     = "A developer toolkit for working with Viaduct from an CLI"
  s.description = "A set of useful tools to help developers use & manage their Viaduct applications."
  s.files = Dir["{bin,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "Gemfile", "Gemfile.lock", "viaduct-toolkit.gemspec", "cacert.pem"]
  s.executables << "vdt"
  s.add_dependency "commander", '~> 4.2'
  s.add_dependency "viaduct-api", '~> 1.0', '>= 1.0.7'
  s.add_dependency "colorize", "~> 0.7"
  s.add_dependency "terminal-table", '~> 1.4', '>= 1.4.5'
  s.add_dependency "launchy", ">= 2.4.2", "< 3.0"
  s.licenses    = ["MIT"]
end
