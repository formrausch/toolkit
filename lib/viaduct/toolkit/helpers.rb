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
      
    end
  end
end
