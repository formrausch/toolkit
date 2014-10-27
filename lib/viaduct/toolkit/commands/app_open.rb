Viaduct::Toolkit.cli.command "app:open" do |c|

  c.syntax = "app:open"
  c.description = "Open application in the Viaduct web UI"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if application = find_application
      system("open https://my.viaduct.io/applications/#{application['subdomain']}")
    end
  end

end

Viaduct::Toolkit.cli.alias_command "open", "app:open"
