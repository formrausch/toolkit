Viaduct::Toolkit.cli.command "app:logs" do |c|
  c.syntax = "app:logs"
  c.description = "Stream logs from the remote server to your screen"
  c.option "--process PROCESS_NAME", String, "Only show logs for the given process"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application
      response = Viaduct::Toolkit.api.applications.status(:application => app['subdomain'])
      if response.success?

        processes = response.data['processes'].select do |p|
          if opts.process
            p['label'] =~ /\A#{opts.process}/
          else
            true
          end
        end

        if processes.empty?
          error "No processes found to stream"
        end

        process_map = processes.inject({}) do |hash, process|
          hash[process['id']] = process['label']
          hash
        end

        require 'eventmachine'

        begin
          EM.run do
            Viaduct::Toolkit.api.push.connected do |event|
              process_map.keys.each do |process_id|
                Viaduct::Toolkit.api.push.subscribe :application_process_logs, process_id
              end
            end

            Viaduct::Toolkit.api.push.receive do |exchange, process_id, data|
              if exchange == :application_process_logs
                tag = "#{process_map[process_id.to_i].rjust(15)}  ".blue
                puts "#{tag} #{data['line']}"
              elsif exchange == :global && data['type'] == 'subscribed'
                puts "Streaming logs for #{process_map[data['routing_key'].to_i]}...".yellow
              end
            end
          end
        rescue Interrupt
          puts "Disconnecting..."
        end
      else
        error "Couldn't get application status to determine process list"
      end
    end
  end

end

Viaduct::Toolkit.cli.alias_command "logs", "app:logs"
