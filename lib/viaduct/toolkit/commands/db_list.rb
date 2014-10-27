Viaduct::Toolkit.cli.command "db:list" do |c|

  c.syntax = "db:list"
  c.description = "List all databases assigned to this application"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application

      shared_databases = Viaduct::Toolkit.api.shared_databases.all(:application => app['subdomain'])
      error "Couldn't get shared databases" unless shared_databases.success?
      dedicated_databases = Viaduct::Toolkit.api.dedicated_databases.all(:application => app['subdomain'])
      error "Couldn't get dedicated databaes" unless dedicated_databases.success?


      rows = []
      shared_databases.data.each do |db|
        rows << [db['fruit'], db['label'], 'Hobby/Dev', db['type'].split('::').last]
      end

      dedicated_databases.data.each do |db|
        rows << [db['fruit'], db['label'], 'Production', db['stack']['name']]
      end

      table ['ID', 'Label', 'Type', 'Engine'], rows.sort_by { |r| r[0] }

    end
  end

end
