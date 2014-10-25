Viaduct::Toolkit.cli.command "app:public_key" do |c|
  c.syntax = "app:public_key"
  c.description = "Return the public key for a given application"
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application
      puts app['public_key'] + " Viaduct key for #{app['subdomain']}"
    end
  end
end
Viaduct::Toolkit.cli.alias_command "app:pk", "app:public_key"
