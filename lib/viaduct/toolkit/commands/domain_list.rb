Viaduct::Toolkit.cli.command "domain:list" do |c|
  c.syntax = "domain:list"
  c.description = "Return a list of domains for an application"
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!
    if app = find_application
      response = Viaduct::Toolkit.api.domains.all(:application => app['subdomain'])
      if response.success?
        rows = response.data.map do |d|
          [d['name'], boolean(d['verification']['verified?']), d['ssl'], d['routing']['cname'], d['routing']['ip']]
        end
        table ['Name', 'Verified', 'SSL', 'CNAME', 'IP'], rows
      else
        error "Couldn't get domain list"
      end
    end
  end
end
