Viaduct::Toolkit.cli.command "app:console" do |c|

  c.syntax = "app:console"
  c.description = "Start a new console session"
  c.option "--disable", "Disable access to the SSH console"
  c.option "--enable", "Enable access to the SSH console"
  c.option "--status", "Display the status of the port forward"
  c.option "-A", "--forward-agent", "Forward agent to this SSH session"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application

      chech_ssh_key_presence
      console = get_application_console_port_forward(app)

      if opts.status
        details do
          heading "SSH console access"
          field "Status", console['enabled'] ? "Enabled" : "Disabled"
          field "Auto disable?", console['auto_disable_at'] ? time(console['auto_disable_at']) : ''
          field "Connection", "#{console['ip_address']}:#{console['port']}"
          console['allowed_ips'].each_with_index do |ip, i|
            field i == 0 ? 'Allowed IPs' : '', ip
          end
        end

      elsif opts.disable

        #
        # Just disable console access
        #

        if console['enabled']
          response = Viaduct::Toolkit.api.port_forwards.save(:id => console['id'], :enabled => 0)
          if response.success?
            puts "Console access has been disabled.".green
          else
            error "We couldn't disable console access at this time. Please try later."
          end
        else
          puts "Console access isn't currently enabled.".yellow
        end

      elsif opts.enable

        #
        # Just enable console access
        #

        if console['enabled']
          puts "Console is already enabled.".yellow
        else
          auto_disable = agree("Would you like to disable this again after an hour?".blue)
          response = Viaduct::Toolkit.api.port_forwards.save(:id => console['id'], :enabled => 1, :auto_disable_at => (auto_disable ? '1 hour from now' : nil))
          if response.success?
            if auto_disable
              puts "Console access has been enaled and will be automatically disabled again in 1 hour.".green
            else
              puts "Console access has been enabled.".green
            end
          else
            error "We couldn't enable console access at this time. Please try later."
          end
        end

      else
        ssh_opts = ["-p #{console['port']}"]
        ssh_opts << "-A" if opts.forward_agent
        exec_console_command(console, "ssh #{ssh_opts.join(' ')} vdt@#{console['ip_address']}")
      end
    end
  end

end

Viaduct::Toolkit.cli.alias_command "console", "app:console"
