Viaduct::Toolkit.cli.command "app:public_key" do |c|
  c.syntax = "app:public_key NAME_OF_APP"
  c.description = "Return the public key for a given application"
  c.action do |args, opts|
    app = Viaduct::Toolkit.api.applications.info(:application => args[0])
    if app.success?
      puts app.data['public_key'] + " Viaduct key for #{app.data['subdomain']}"
    else
      puts "Application not found matching '#{args[0]}'".red
      Process.exit(1)
    end
  end
end
Viaduct::Toolkit.cli.alias_command "app:pk", "app:public_key"