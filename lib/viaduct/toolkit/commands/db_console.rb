Viaduct::Toolkit.cli.command "db:console" do |c|

  c.syntax = "db:console"
  c.description = "Open a console session for the given database"
  c.option "-d FRUIT", "--database FRUIT", String, "The name of the database to import into (uses the main DB by default)"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    app = find_application
    database = find_database(app, opts.database)

    if command = database['database']['console_command']
      chech_ssh_key_presence
      console = get_application_console_port_forward(app)
      exec_console_command(console, "ssh -t vdt@#{console['ip_address']} -p #{console['port']} '#{command}'")
    else
      puts "Console access is not available for this database type.".red
      exit 1
    end
  end

end
