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
  s.files       = Dir["{bin,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "Gemfile", "Gemfile.lock", "viaduct-toolkit.gemspec", "cacert.pem"]
  s.executables << "vdt"
  s.licenses    = ["MIT"]
  s.add_dependency 'bundler', '>= 1.10.5'
  s.add_dependency 'addressable', '= 2.3.6'
  s.add_dependency 'colorize', '= 0.7.3'
  s.add_dependency 'commander', '= 4.2.1'
  s.add_dependency 'eventmachine', '= 1.0.7'
  s.add_dependency 'faye-websocket', '= 0.8.0'
  s.add_dependency 'highline', '= 1.6.21'
  s.add_dependency 'json', '= 1.8.1'
  s.add_dependency 'launchy', '= 2.4.3'
  s.add_dependency 'moonrope-client', '= 1.0.1'
  s.add_dependency 'rake', '= 10.4.2'
  s.add_dependency 'terminal-table', '= 1.4.5'
  s.add_dependency 'viaduct-api', '= 1.0.7'
  s.add_dependency 'websocket-driver', '= 0.4.0'
end
