Viaduct::Toolkit.cli.command "app:deployment" do |c|
  
  c.syntax = "app:deployment"
  c.description = "Get details of the current deployment"
  c.action do |args, opts|
    include Commander::Methods
    if application = find_application(args[0])
      response = Viaduct::Toolkit.api.applications.deployment(:application => application['subdomain'])
      if response.success?
        details do
          heading "Deployment Details"
          field "Number", response.data['number']
          field "Status", response.data['status'].to_s.capitalize
          field "Deployer", response.data['user'] ? "#{response.data['user']['name']} (#{response.data['user']['username']})" : ''
          
          heading "Version Details"
          field "Description", response.data['version']['description']
          field "ID", response.data['version']['id']
          field "Author", "#{response.data['version']['author']['name']} <#{response.data['version']['author']['email']}>"
          
          heading "Timing"
          field "Created", response.data['timing']['created_at']
          field "Started", response.data['timing']['started_at']
          field "Finished", response.data['timing']['finished_at']
          field "Time", response.data['timing']['time'].round(2).to_s + "s"
          
          heading "Processes"
          response.data['processes'].each do |p|
            field p['label'], "#{p['memory_allocation']['memory'] / 1024 / 1024}MB memory allocation"
          end
        end
      else
        error "Couldn't get deployment details"
      end
    end
  end
end
