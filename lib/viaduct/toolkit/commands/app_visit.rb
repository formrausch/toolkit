Viaduct::Toolkit.cli.command "app:visit" do |c|

  c.syntax = "app:visit"
  c.description = "Visit application in a web browser"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if application = find_application
      require 'launchy'
      Launchy.open("https://#{application['main_domain'] ? application['main_domain']['name'] : application['viaduct_domain']}")
    end
  end

end

Viaduct::Toolkit.cli.alias_command "visit", "app:visit"
