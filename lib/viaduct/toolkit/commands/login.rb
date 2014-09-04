Viaduct::Toolkit.cli.command "login" do |c|
  c.syntax = "login"
  c.description = "Authenticate this computer with your Viaduct account"
  c.action do |args, options|
    
    Viaduct::Toolkit.config['token'] = nil
    Viaduct::Toolkit.config['secret'] = nil
    Viaduct::Toolkit.save_config
    
    response = Viaduct::Toolkit.api.authentication.create_login_token
    if response.success?
      puts
      puts "  A browser window should now open and allow you to login"
      puts "  to your Viaduct account. Please login and return here"
      puts "  when you're finished."
      puts
      puts "  Please wait while we verify your login..."
      puts
      system("open", response.data['url'])
      check_response = nil
      100.times do
        sleep 3
        check_response = Viaduct::Toolkit.api.authentication.exchange(:token => response.data['token'])
        if check_response.success?
          if check_response.data['status'] == 'approved'
            Viaduct::Toolkit.reset_api
            @authorised = true
            break
          elsif check_response.data['status'] == 'denied'
            raise Viaduct::Toolkit::Error, "The login request was rejected. Ensure that you approve the login request."
          end
        else
          raise Viaduct::Toolkit::Error, "Couldn't successfully exchange login token for an API token. Please try again later."
        end
      end
      
      if @authorised
        Viaduct::Toolkit.config['token'] = check_response.data['token']['token']
        Viaduct::Toolkit.config['secret'] = check_response.data['token']['secret']

        user_check = Viaduct::Toolkit.api.user.details
        if user_check.success?
          Viaduct::Toolkit.save_config
          puts "  Hello #{user_check.data['name']}!".green
          puts "  Your user account is now authorised. Your login details are".green
          puts "  stored in a .viaduct file in your home directory.".green
          puts
        else
          raise Viaduct::Toolkit::Error, "We couldn't verify your user details. Please try again."
        end
      else
        raise Viaduct::Toolkit::Error, "We didn't receive a login response in a timely manner. Please try again."
      end
      
    else
      raise Viaduct::Toolkit::Error, "Couldn't generate a remote login token. Please try again."
      Process.exit(1)
    end
    
  end
end