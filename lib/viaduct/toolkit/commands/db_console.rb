Viaduct::Toolkit.cli.command "db:console" do |c|

  c.syntax = "db:console"
  c.description = "Open a console session for the given database"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    if args[0].nil?
      error "You need to specify a database name"
    end
    if app = find_application
      database = Viaduct::Toolkit.api.applications.database(:application => app['subdomain'], :database => args[0])
      if database.status == 'not-found'
        puts "No database found named '#{args[0]}'".red
        exit 1
      end

      error "Couldn't get database details" unless database.success?
      if command = database.data['database']['console_command']
        chech_ssh_key_presence
        console = get_application_console_port_forward(app)
        puts command
        exec_console_command(console, "ssh -t vdt@#{console['ip_address']} -p #{console['port']} '#{command}'")
      else
        puts "Console access is not available for this database type.".red
        exit 1
      end
    end
  end

end
