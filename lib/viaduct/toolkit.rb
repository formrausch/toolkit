require 'yaml'
require 'colorize'
require 'commander'
require 'viaduct/toolkit/version'
require 'viaduct/api'

# Hardcoded for this application.
Viaduct::API.application_token = '3148984b-8a50-424c-98f5-117e8dea2971'

module Viaduct
  module Toolkit
    
    class Error < StandardError
    end
    
    class << self
      def cli
        @cli ||= begin
          c = Commander::Runner.instance
          c.program :name, "Viaduct Toolkit"
          c.program :version, Viaduct::Toolkit::VERSION
          c.program :description, "A CLI toolkit for Viaduct developers"
          c.global_option('-c', '--config FILE', 'The config file to store local credentials within') { |file| $config_file_path = file }
          c
        end
      end
    
      def add_commands
        Dir[File.expand_path(File.join('..', 'toolkit', 'commands', '*.rb'), __FILE__)].each do |file|
          require file
        end
      end
    
      def api
        @api ||= begin
          Viaduct::API::Client.new(config['token'], config['secret'])
        end
      end
      
      def reset_api
        @api = nil
      end
    
      def config_file_path
        $config_file_path || File.join(ENV['HOME'], '.viaduct')
      end
    
      def config
        @config ||= begin
          if File.exist?(config_file_path)
            YAML.load_file(config_file_path)
          else
            {}
          end
        end
      end
    
      def save_config
        File.open(config_file_path, 'w') do |f|
          f.write self.config.to_yaml
        end
      end
      
      def check_logged_in!
        puts config.inspect
        if config['token'].nil? && config['secret'].nil?
          raise Error, "You're not logged in. Use 'login' to login before running other commands."
        end
      end
    end
  end
end
