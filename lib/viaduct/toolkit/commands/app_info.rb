Viaduct::Toolkit.cli.command "app:info" do |c|

  c.syntax = "app:info"
  c.description = "Show details of an existing application"
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if application = find_application
      details do
        heading "Application Details"
        field "Name", application['name']
        field "Viaduct Domain", application['viaduct_domain']
        field "Status", application['status']
        field "Maintenance", application['maintenance?'] ? 'Yes' : 'No'
        field 'Owner', "#{application['user']['name']} (#{application['user']['username']})"
        field "Zone", application['zone']['name']
        field "Platform", "#{application['platform']['name']} (on #{application['platform']['stack']['name']} stack)"
        field "Subnet(s)", application['subnets'].map { |s| s['description'] }.join(', ')
        if application['repository'] && application['source_backend_module'] == 'Viaduct::SourceBackends::Repository'
          heading "Repository"
          field 'URL', application['repository']['repository']['url']
          field 'Status', application['repository']['repository']['status']
          field 'Last update', application['repository']['repository']['last_updated_at']
          field 'Username', application['repository']['repository']['username']
          field 'Branch', application['repository']['branch']
        end

        if application['deployment']
          heading "Active Deployment"
          field 'Number', application['deployment']['number']
          field 'Started at', application['deployment']['timing']['created_at']
          field 'Time', application['deployment']['timing']['time'].round(1).to_s + "s"
          field 'Description', application['deployment']['version']['description']
          field 'Source', application['deployment']['triggered_from']
          if application['deployment']['user']
            field 'Deployer', "#{application['deployment']['user']['name']} (#{application['deployment']['user']['username']})"
          elsif application['deployment']['triggerer']
            field 'Deployer', application['deployment']['triggerer']
          end
        end
      end
    end
  end

end
