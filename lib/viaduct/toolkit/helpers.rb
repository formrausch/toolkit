require 'open3'

module Viaduct
  module Toolkit
    module Helpers
      def ensure_logged_in!
        if Viaduct::Toolkit.env_config['token'].nil? && Viaduct::Toolkit.env_config['secret'].nil?
          puts "You need to login before using this toolkit. Use the command below".yellow
          puts "to login to your Viaduct account.".yellow
          puts
          puts "  $ vdt login"
          puts
          exit 1
        end
      end

      def length_of_time(seconds)
        "#{seconds} seconds"
      end

      def time(time)
        require 'time'
        time = Time.parse(time) rescue nil
        time ? time.strftime("%d %B %Y at %H:%M:%S UTC") : ''
      end

      def boolean(bool)
        bool ? "\u2713".green : "-".red
      end

      def table(headings, rows)
        require 'terminal-table'
        puts Terminal::Table.new :rows => rows, :headings => headings.map(&:blue)
      end

      def validation_errors(errors)
        errors.each do |field, messages|
          messages.each do |message|
            puts " * #{field} #{message}".red
          end
        end
      end

      def error(message)
        raise Viaduct::Toolkit::Error, message
      end

      def run(*commands)
        stdin, stdout, stderr, w = Open3.popen3(*commands)
        [stdout.gets(nil), stderr.gets(nil), w.value]
      end

      def find_application
        if $app.is_a?(String) && $app.length > 0
          app = Viaduct::Toolkit.api.applications.info(:application => $app)
          if app.success?
            return app.data
          else
            puts "Couldn't find application with subdomain matching '#{$app}'".red
            exit(1)
          end
        else
          # Look up from repo
          out, err, status = run("git", "remote", "-v")
          if status == 0
            potential_repositories = out.split("\n").map { |l| l.split(/\s+/)[1] }.uniq
            app = Viaduct::Toolkit.api.applications.all(:filter => {:repo => potential_repositories})
            if app.success?
              if app.data.empty?
                puts "No Viaduct applications found for any of the following repositories:".red
                potential_repositories.each do |repo|
                  puts "  * #{repo}".red
                end
                exit(1)
              elsif app.data.size == 1
                $app = app.data.first['subdomain']
                return find_application
              else
                puts "Multiple applications found matching your repository. Choose an application...".yellow
                choice = choose('', *app.data.map { |a| "#{a['subdomain']}: #{a['name']}"})
                choice = choice.split(":", 2).first
                $app = choice
                return find_application()
              end
            end
          end
        end

        puts "Couldn't determine a Viaduct application from command.".red
        exit(1)
      end

      def heading(title)
        puts "+" + ("-" * 78) + "+"
        puts "| #{title.ljust(76).yellow} |"
        puts "+" + ("-" * 78) + "+"
      end

      def field(key, value)
        key = key[0,16].ljust(16, ' ')
        value = value.to_s[0,58].ljust(58)

        puts "| #{key.blue}| #{value} |"
      end

      def details(&block)
        block.call
        puts "+" + ("-" * 78) + "+"
      end

      def chech_ssh_key_presence
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
      end

      def get_application_console_port_forward(app)
        response = Viaduct::Toolkit.api.port_forwards.all(:application => app['subdomain'])
        if response.success?
          if console = response.data.select { |c| c['mode'] == 'console'}.first
            console
          else
            error "Console access is not supported by this application. Please contact support."
          end
        else
          error "Couldn't get port forward information from API for application."
        end
      end

      def exec_console_command(console, command)
        unless console['enabled']
          puts "SSH Console access is not currently enabled for this application. Enabling...".magenta
          response = Viaduct::Toolkit.api.port_forwards.save(:id => console['id'], :enabled => 1, :auto_disable_at => '5 minutes from now')
          unless response.success?
            error "We couldn't enable console access at this time. Please try later."
          end
        end
        puts "Connecting...".magenta
        exec(command)
      end

    end
  end
end
