require 'yaml'
require 'colorize'
require 'commander'
require 'viaduct/toolkit/version'
require 'viaduct/api'

# Hardcoded for this application.
Viaduct::API.application_token = '3148984b-8a50-424c-98f5-117e8dea2971'

# Add our helpers to Commander
require 'viaduct/toolkit/helpers'
Commander::Methods.send :include, Viaduct::Toolkit::Helpers

module Viaduct
  module Toolkit

    class Error < StandardError
    end

    class << self

      def binary
        File.expand_path(File.join('..', '..', '..', 'bin', 'viaduct'), __FILE__)
      end

      def cli
        @cli ||= begin
          c = Commander::Runner.instance
          c.program :name, "Viaduct Toolkit"
          c.program :version, Viaduct::Toolkit::VERSION
          c.program :description, "A CLI toolkit for Viaduct developers"
          c.global_option('-c', '--config FILE', 'The config file to store local credentials within') { |file| $config_file_path = file }
          c.global_option('--app NAME', 'The application to work on') { |name| $app = name }
          c.global_option('--dev', 'Connect to local development installation of Viaduct (dev only)') { $dev = true }
          c.default_command :help
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
          if $dev
            Viaduct::API.host = 'localhost'
            Viaduct::API.port = 5000
            Viaduct::API.ssl = false
            Viaduct::API.application_token = 'example'
          end
          Viaduct::API::Client.new(env_config['token'], env_config['secret'])
        end
      end

      def reset_api
        @api = nil
      end

      def config_file_path
        $config_file_path || File.join(ENV['HOME'], '.viaduct')
      end

      def env_config
        config[$dev ? 'dev' : 'live'] ||= {}
      end

      def config
        @config ||= begin
          if File.exist?(config_file_path)
            YAML.load_file(config_file_path) || {}
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

    end
  end
end
