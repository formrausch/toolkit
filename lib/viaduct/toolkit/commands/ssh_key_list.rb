Viaduct::Toolkit.cli.command "ssh_key:list" do |c|

  c.syntax = "ssh_key:list"
  c.description = "List the keys associated with your account"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    response = Viaduct::Toolkit.api.ssh_keys.all
    if response.success?
      require 'terminal-table'
      rows = response.data.map do |app|
        [app['label'], app['fingerprint']]
      end
      table = Terminal::Table.new :rows => rows, :headings => ['Label', 'Fingerprint']
      puts table

    else
      error "Couldn't get the SSH key list."
    end

  end

end

