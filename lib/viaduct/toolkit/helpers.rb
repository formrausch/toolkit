require 'open3'

module Viaduct
  module Toolkit
    module Helpers
      
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
      
      def find_application(subdomain)
        if subdomain.is_a?(String) && subdomain.length > 0
          app = Viaduct::Toolkit.api.applications.info(:application => subdomain)
          if app.success?
            return app.data
          else
            puts "Couldn't find application with subdomain matching '#{subdomain}'".red
            Process.exit(1)
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
                Process.exit(1)
              elsif app.data.size == 1
                return find_application(app.data.first['subdomain'])
              else
                puts "Multiple applications found matching your repository. Choose an application...".yellow
                choice = choose('', *app.data.map { |a| "#{a['subdomain']}: #{a['name']}"})
                choice = choice.split(":", 2).first
                return find_application(choice)
              end
            end
          end
        end
        
        puts "Couldn't determine a Viaduct application from command.".red
        Process.exit(1)
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
