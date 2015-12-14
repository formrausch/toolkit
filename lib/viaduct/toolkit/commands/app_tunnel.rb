Viaduct::Toolkit.cli.command "app:tunnel" do |c|

  c.syntax = "app:tunnel"
  c.description = "Start a new SSH tunnel session so you can securely connect to internal parts of your application"
  c.option "--ip REMOTE_IP", String, "The remote IP address to tunnel to"
  c.option "-r REMOTE_PORT", "--remote REMOTE_PORT", String, "The remote port to tunnel to"
  c.option "-l LOCAL_PORT", "--local LOCAL_PORT", String, "The local port to point to the remote port"
  c.option "-d DATABASE_NAME", "--db DATABASE_NAME", String, "The name of a database to establish a tunnel to (no need to provide --ip or --remote)"
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application

      chech_ssh_key_presence
      console = get_application_console_port_forward(app)

      remote_ip = opts.ip
      remote_port = opts.remote
      local_port = opts.local

      if opts.db
        database = find_database(app, opts.db)
        remote_ip = database['database']['env_vars']["VDT_DB_#{opts.db.to_s.upcase}_HOST"]
        remote_port = database['database']['env_vars']["VDT_DB_#{opts.db.to_s.upcase}_PORT"]
      end

      if remote_ip.nil?
        error "Must specify an remote IP using --ip"
      end

      if remote_port.nil?
        error "Must specify a remote port using --remote"
      end

      if local_port.nil?
        error "Must specify a local port using --local"
      end

      ssh_opts = [
        "-p #{console['port']}",
        "-L #{local_port}:#{remote_ip}:#{remote_port}"
      ]
      cmd = "echo -n 'Your tunnel to \e[34m#{remote_ip}:#{remote_port}\e[0m is established on \e[32m127.0.0.1:#{local_port}\e[0m.\nPress CTRL+C to close this connection...'; sleep infinity"
      exec_console_command(console, "ssh #{ssh_opts.join(' ')} vdt@#{console['ip_address']} \"#{cmd}\"")
    end
  end

end

Viaduct::Toolkit.cli.alias_command "tunnel", "app:tunnel"
