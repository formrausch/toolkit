Viaduct::Toolkit.cli.command "login" do |c|
  c.syntax = "login"
  c.description = "Authenticate this computer with your Viaduct account"
  c.action do |args, options|
    
    Viaduct::Toolkit.config['token'] = nil
    Viaduct::Toolkit.config['secret'] = nil
    Viaduct::Toolkit.save_config
    
    response = Viaduct::Toolkit.api.authentication.create_login_token
    if response.success?
      
      puts "To log you in we need to open a browser window to allow".magenta
      puts "you to enter your login details. ".magenta
      puts
      if agree("Shall we open this for you?".blue)
        system("open", response.data['url'])
      else
        puts
        puts "That's fine. Just go to the URL below in your browser.".magenta
        puts "This command will continue to run until you complete this".magenta
        puts "action.".magenta
        puts
        puts response.data['url']
      end
      
      puts
      puts "Please wait while we verify your login...".magenta
      puts
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
            error "The login request was rejected. Ensure that you approve the login request."
          end
        else
          error "Couldn't successfully exchange login token for an API token. Please try again later."
        end
      end
      
      if @authorised
        Viaduct::Toolkit.config['token'] = check_response.data['token']['token']
        Viaduct::Toolkit.config['secret'] = check_response.data['token']['secret']

        user_check = Viaduct::Toolkit.api.user.details
        if user_check.success?
          Viaduct::Toolkit.save_config
          puts "Hello #{user_check.data['name']}!".green
          puts "Your user account is now authorised. Your login details are".magenta
          puts "stored in a .viaduct file in your home directory.".magenta
          puts
        else
          error "We couldn't verify your user details. Please try again."
        end
      else
        error "We didn't receive a login response in a timely manner. Please try again."
      end
      
    else
      error "Couldn't generate a remote login token. Please try again."
    end
    
  end
end