Viaduct::Toolkit.cli.command "app:env" do |c|
  
  c.syntax = "app:env"
  c.description = "Show all environment variables for an application"
  c.option "--simple", "Return environment variables "
  c.option "--yaml", "Return environment variables as YAML file"
  c.option "--export", "Return environment variables as export lines"
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if application = find_application
      response = Viaduct::Toolkit.api.applications.environment_variables(:application => application['subdomain'])
      if response.success?
        if opts.simple
          response.data.each do |key, value|
            puts "#{key}: #{value}"
          end
        elsif opts.yaml
          require 'yaml'
          puts response.data.to_yaml
        elsif opts.export
          response.data.each do |key, value|
            puts "export #{key}=\"#{value}\""
          end
        else
          require 'terminal-table'
          puts Terminal::Table.new :rows => response.data.to_a
        end
      else
        error "Couldn't get environment variables"
      end
    end
  end

end
