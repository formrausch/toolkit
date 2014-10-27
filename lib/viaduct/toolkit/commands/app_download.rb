Viaduct::Toolkit.cli.command "app:download" do |c|

  c.syntax = "app:download [REMOTE_PATH] [LOCAL_PATH]"
  c.description = "Download files from your application"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application

      if args[0].nil?
        error "must specify path to file to download"
      end

      chech_ssh_key_presence
      console = get_application_console_port_forward(app)
      exec_console_command(console, "scp -r -P #{console['port']} vdt@#{console['ip_address']}:#{args[0]} #{args[1] || './'}")
    end
  end

end

Viaduct::Toolkit.cli.alias_command "download", "app:download"
