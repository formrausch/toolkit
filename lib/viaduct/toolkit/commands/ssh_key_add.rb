Viaduct::Toolkit.cli.command "ssh_key:add" do |c|

  c.syntax = "ssh_keys:add PATH_TO_PUBLIC_KEY"
  c.description = "Add a new SSH public key to your user account"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    key_path = args[0]

    default_key_path = File.join(ENV['HOME'], '.ssh', 'id_rsa.pub')
    if key_path.nil? && File.exist?(default_key_path)
      puts "You haven't provided an SSH key to this command.".yellow
      if agree("Shall we use your default key at #{default_key_path}?".blue)
        key_path = default_key_path
      else
        exit(1)
      end
    end

    if File.exist?(key_path)
      response = Viaduct::Toolkit.api.ssh_keys.add(:label => "Added from #{`hostname`}", :key => File.read(key_path))
      if response.success?
        puts "Key successfully added to your account".green
      else
        if response.is_a?(MoonropeClient::Responses::ValidationError)
          puts "Errors occurred while adding your key:".red
          validation_errors response.data['errors']
        else
          error "Couldn't add your key"
        end
      end
    else
      puts "No public key found at '#{key_path}'".red
      exit(1)
    end
  end

end
