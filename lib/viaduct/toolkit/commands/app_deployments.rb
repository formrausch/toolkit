Viaduct::Toolkit.cli.command "app:deployments" do |c|
  
  c.syntax = "app:deployments SUBDOMAIN_OF_APP"
  c.description = "List all deployments for an application"
  c.option "--page PAGE", Integer, "The page of deployments to return"
  
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if application = find_application(args[0])
      response = Viaduct::Toolkit.api.applications.deployments(:application => application['subdomain'], :page => opts.page ? opts.page.to_i : 1)
      if response.success?

        require 'terminal-table'
        rows = response.data.map do |d|
          [d['number'], d['status'], d['version']['description'].to_s[0,30], d['user'] ? d['user']['username'] : '', d['timing']['created_at']]
        end
        puts Terminal::Table.new :rows => rows, :headings => ['#', 'Status', 'Description', 'User', 'Time']
        
      else
        error "Couldn't get application deployment list"
      end
    end
  end
end
