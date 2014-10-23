Viaduct::Toolkit.cli.command "app:deployments" do |c|
  
  c.syntax = "app:deployments"
  c.description = "List all deployments for an application"
  c.option "--page PAGE", Integer, "The page of deployments to return"
  
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if application = find_application
      response = Viaduct::Toolkit.api.applications.deployments(:application => application['subdomain'], :page => opts.page ? opts.page.to_i : 1)
      if response.success?

        require 'terminal-table'
        
        colourer = Proc.new do |d, field|
          if d['status'] == 'deployed'
            field.to_s.green
          elsif d['status'] == 'failed'
            field.to_s.red
          else
            field
          end
        end
        
        rows = response.data.map do |d|
          [
            colourer.call(d, d['number']),
            colourer.call(d, d['version']['description'].to_s[0,30]),
            colourer.call(d, d['user'] ? d['user']['username'] : d['triggerer']),
            colourer.call(d, d['timing']['created_at']),
            colourer.call(d, d['triggered_from'])
          ]
        end
        puts Terminal::Table.new :rows => rows, :headings => ['#', 'Description', 'User', 'Time', 'Source']
        puts "The active deployment shows in #{'green'.green} and failed show in #{'red'.red}."
      else
        error "Couldn't get application deployment list"
      end
    end
  end
end
