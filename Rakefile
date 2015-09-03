task :add_dependencies_to_gemspec do
  root = File.expand_path('..', __FILE__)
  dep_list = []
  gemfile = Bundler::LockfileParser.new(File.read(File.join(root, 'Gemfile.lock')))
  dep_list << "  s.add_dependency 'bundler', '>= 1.10.5'"
  gemfile.specs.each do |dep|
    dep_list << "  s.add_dependency '#{dep.name}', '= #{dep.version}'"
  end
  gemspec_path = File.join(root, 'viaduct-toolkit.gemspec')
  gemspec = File.read(gemspec_path)
  gemspec.gsub!(/^\s*s.add_dependency(.*)^end/m, dep_list.join("\n") + "\nend")
  File.open(gemspec_path, 'w') { |f| f.write(gemspec) }
end
