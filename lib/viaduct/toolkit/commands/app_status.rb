Viaduct::Toolkit.cli.command "app:status" do |c|
  c.syntax = "app:status NAME_OF_APP"
  c.description = "Return current status of an application"
  c.option "--process PROCESS_TYPE", String, "A process to show expanded information for"
  c.option "--database DATABASE_ID", String, "The ID of the database to display further information for"
  
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application(args[0])
      response = Viaduct::Toolkit.api.applications.status(:application => app['subdomain'])
      if response.success?
        
        if opts.process
          
          if process = response.data['processes'].select { |p| p['label'] == opts.process.to_s }.first
            details do
              heading "Details"
              field "Label", process['label']
              field "Command", process['container']['command']
              field "Public?", process['container']['public'] ? 'Yes' : 'No'
              field "Status", process['process']['status'].capitalize
              process_details(process['process'])
            end
          else
            puts "No process found matching '#{opts.process}'".red
            exit 1
          end
          
          
        elsif opts.database
          
          if db = response.data['databases'][(opts.database.to_i - 1).abs]
            details do
              heading "Database Details"
              field "Label", db['label']
              field "Database", db['stack']['name']
              process_details(db['process'])
            end
          else
            puts "No database found with ID '#{opts.database}'".red
            exit 1
          end
          
        else
        
          puts "Deployment Details".yellow
          details do
            puts "+" + '-' * 78 + '+'
            field "Number", response.data['deployment']['number']
            field 'Version', response.data['deployment']['version']['id']
            field "Description", response.data['deployment']['version']['description']
            field "Source", response.data['deployment']['triggered_from']
            field "Deployer", response.data['deployment']['user'] ? response.data['deployment']['user']['full_name'] : response.data['deployment']['triggerer']
            field "Started", time(response.data['deployment']['timing']['started_at'])
          end
        
          processes = response.data['processes'].map do |p|
            memory_used = (p['process']['resources']['memory_usage'] / 1024 / 1024).to_s + "MB"
            memory_available = (p['process']['resources']['max_memory'] / 1024 / 1024).to_s + "MB"
            memory = "#{memory_used}/#{memory_available}"
          
            respawns = "#{p['process']['respawning']['current']}/#{p['process']['respawning']['maximum']}"
            [p['label'], p['process']['status'].capitalize, memory, p['container']['command'], respawns]
          end
          puts
          puts "Processes".yellow
          table ['Label', 'Status', 'Memory', 'Command', 'Respawns'], processes
          
          count = 0
          databases = response.data['databases'].map do |d|
            count += 1
            memory_used = (d['process']['resources']['memory_usage'] / 1024 / 1024).to_s + "MB"
            memory_available = (d['process']['resources']['max_memory'] / 1024 / 1024).to_s + "MB"
            memory = "#{memory_used}/#{memory_available}"
            respawns = "#{d['process']['respawning']['current']}/#{d['process']['respawning']['maximum']}"
          
            [count, d['label'], d['process']['status'].capitalize, d['stack']['name'], memory, respawns, d['process']['networking']['ip_address']]
          end
          unless databases.empty?
            puts
            puts "Dedicated Databases".yellow
            table ['#', 'Label', 'Status', 'Type', 'Memory', 'Respawns', 'IP Address'], databases
          end
        end
        
      else
        error "Couldn't get application status"
      end
    end
  end
end

def process_details(p)
  if p['host'] && p['lxc_name']
    heading "Host (admin only)"
    field "Host", p['host']
    field "LXC Name", p['lxc_name']
  end
  
  heading "Networking"
  field "IP Address", p['networking']['ip_address']
  field "MAC Address", p['networking']['mac_address']
  field "Data", "RX: #{p['networking']['rx']}   TX: #{p['networking']['tx']}"
  
  heading "Timing"
  field "Started", time(p['timing']['started'])
  field "Run time", length_of_time(p['timing']['run_time'])
  field "Last seen", time(p['timing']['last_seen_at'])
  
  heading "Resources"
  field "Memory", "#{p['resources']['memory_usage'] /1024/1024}MB of #{p['resources']['max_memory']/1024/1024}MB"
  field "CPU Usage", p['resources']['cpu_usage']
  
  heading "Respawning"
  field "Respawns", "#{p['respawning']['current']} / #{p['respawning']['maximum']}"
  field "Last respawn", time(p['respawning']['last'])

end
