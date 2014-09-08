Viaduct::Toolkit.cli.command "app:console" do |c|
  
  c.syntax = "app:console SUBDOMAIN_OF_APP"
  c.description = "Start a new SSH-based console session"
  c.option "--disable", "Disable access to the SSH console"
  c.option "--enable", "Enable access to the SSH console"
  c.option "--status", "Display the status of the port forward"
  
  c.action do |args, opts|
    include Commander::Methods
    if app = find_application(args[0])
      
      # Check the user's SSH keys
      response = Viaduct::Toolkit.api.ssh_keys.all
      if response.success?
        
        if response.data.empty?
          puts "You haven't uploaded any SSH keys to your Viaduct user account.".red
          puts "You cannot use SSH console access without them.".red
          puts
          puts "Upload your key using the command below".blue
          puts
          puts "    $ vdt ssh_keys:add".blue
          puts
          exit(1)
        else
          stdout, stderr, status = run("ssh-add -l")
          if status == 0
            remote_fingerprints = response.data.map { |d| d['fingerprint'] }
            local_fingerprints = stdout.split(/\n/).map { |l| l.split(/\s+/)[1] }
            unless remote_fingerprints.any? { |f| local_fingerprints.include?(f) }
              puts "Warning: it doesn't seem as though your SSH key has been uploaded".yellow
              puts "to your Viaduct account. This session may not succeed. If it doesn't".yellow
              puts "ensure that you have uploaded to your SSH key to your Viaduct account.".yellow
            end
          end
        end
        
      else
        error "Couldn't verify remote SSH keys. Please try again."
      end
      
      # Get the console port forward for the application
      response = Viaduct::Toolkit.api.port_forwards.all(:application => app['subdomain'])
      if response.success?
        unless console = response.data.select { |c| c['mode'] == 'console'}.first
          error "Console access is not supported by this application. Please contact support."
        end
      else
        error "Couldn't get port forward information from API for application."
      end
      
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
        
        #
        # Enable if needed and connect.
        #
        unless console['enabled']
          puts "SSH Console access is not currently enabled for this application.".magenta
          if enable =  agree("Would you like to enable it now?".blue)
            disable_after_hour = agree("Would you like to disable this again after an hour?".blue)
            response = Viaduct::Toolkit.api.port_forwards.save(:id => console['id'], :enabled => 1, :auto_disable_at => (disable_after_hour ? "1 hour from now" : nil))
            unless response.success?
              puts response.inspect
              error "We couldn't enable console access at this time. Please try later."
            end
          else
            puts "Unfortunately, unless enabled you cannot use this command.".red
            exit(1)
          end
        end
        
        command = "ssh vdt@#{console['ip_address']} -p #{console['port']}"
        
        exec(command)
      end
      
      
    end
  end
  
end


Viaduct::Toolkit.cli.alias_command "app:ssh", "app:console"