Viaduct::Toolkit.cli.command "app:list" do |c|
  c.syntax = "app:list"
  c.description = "Show a list of all applications you have access to"
  c.option "--simple", "Return just a list of subdomains"
  c.action do |args, opts|
    pages_seen = 0
    applications = []
    loop do
      response = Viaduct::Toolkit.api.applications.all(:page => pages_seen + 1)
      if response.success?
        applications = applications | response.data
      else
        error "Couldn't get list of applications."
      end
      pages_seen += 1
      if pages_seen == response.flags['paginated']['page']
        break
      end
    end

    if opts.simple
      applications.each do |application|
        puts application['subdomain']
      end
    else
      require 'terminal-table'
      rows = applications.map do |app|
        [app['name'], app['subdomain'], app['status'], app['user']['name']]
      end
      puts Terminal::Table.new :rows => rows, :headings => ['Name', 'Subdomain', 'Status', 'Owner']
    end
    
  end
end
