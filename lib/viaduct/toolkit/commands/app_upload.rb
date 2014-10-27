Viaduct::Toolkit.cli.command "app:upload" do |c|

  c.syntax = "app:upload [LOCAL_PATH] [REMOTE_PATH]"
  c.description = "Upload files to your application"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application

      if args[0].nil?
        error "must specify path to file to upload"
      end

      chech_ssh_key_presence
      console = get_application_console_port_forward(app)
      exec_console_command(console, "scp -r -P #{console['port']} #{args[0]} vdt@#{console['ip_address']}:#{args[1] || './'}")
    end
  end

end

Viaduct::Toolkit.cli.alias_command "upload", "app:upload"
