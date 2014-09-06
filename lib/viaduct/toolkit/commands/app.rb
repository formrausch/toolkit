Viaduct::Toolkit.cli.command "app" do |c|
  
  c.syntax = "app SUBDOMAIN_OF_APP"
  c.description = "Show details of an existing application"
  c.action do |args, opts|
    response = Viaduct::Toolkit.api.applications.info(:application => args[0])
    if response.success?
      puts "=" * 80
      puts "Application Details"
      puts "=" * 80
      
      puts "Name..............: #{response.data['name']}"
      puts "Viaduct Domain....: #{response.data['viaduct_domain']}"
      puts "Status............: #{response.data['status']}"
      puts "Maintenance.......: #{response.data['maintenance?'] ? 'Yes' : 'No'}"
      puts "Owner.............: #{response.data['user']['name']} (#{response.data['user']['username']})"
      puts "Zone..............: #{response.data['zone']['name']}"
      puts "Platform..........: #{response.data['platform']['name']} (on #{response.data['platform']['stack']['name']} stack)"
      if response.data['repository'] && response.data['source_backend_module'] == 'Viaduct::SourceBackends::Repository'
        puts "=" * 80
        puts "Repository"
        puts "=" * 80
        puts "URL...............: #{response.data['repository']['repository']['url']}"
        puts "Status............: #{response.data['repository']['repository']['status']}"
        puts "Last Updated......: #{response.data['repository']['repository']['last_updated_at']}"
        puts "Username..........: #{response.data['repository']['repository']['username']}"
        puts "Branch............: #{response.data['repository']['branch']}"
      end
      
      if response.data['deployment']
        puts "=" * 80
        puts "Active Deployment"
        puts "=" * 80
        puts "Number............: #{response.data['deployment']['number']}"
        puts "Deployed at.......: #{response.data['deployment']['timing']['created_at']}"
        puts "Deployment time...: #{response.data['deployment']['timing']['time'].round(1)}s"
        puts "Description.......: #{response.data['deployment']['version']['description']}"
        puts "Deployer..........: #{response.data['deployment']['user']['name']} (#{response.data['deployment']['user']['username']})"
      end
    else
      raise Viaduct::Toolkit::Error, "Application doesn't exist with subdomain '#{args[0]}'"
    end
  end
  
end