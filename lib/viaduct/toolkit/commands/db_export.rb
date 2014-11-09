Viaduct::Toolkit.cli.command "db:export" do |c|

  c.syntax = "db:export [PATH]"
  c.description = "Download an export for a given database"
  c.option "-d FRUIT", "--database FRUIT", String, "The name of the database to export (uses the main DB by default)"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    # Get the application
    app = find_application

    # Is there a DB?
    if opts.database
      database_fruit = opts.database
    elsif app['main_database']
      database_fruit = app['main_database']['fruit']
    else
      puts "There is no database specified and you don't have a main database for".red
      puts "this application. Try again using the --database option.".red
      exit 1
    end

    # Get the database
    database = Viaduct::Toolkit.api.applications.database(:application => app['subdomain'], :database => database_fruit)
    if database.success?
      database = database.data
    else
      puts "No database found matching '#{opts.database}'".red
      exit 1
    end

    # Set some parameters to create our new  export with
    export_params = {}
    export_params[:application] = app['subdomain']
    export_params[:database]    = database['database']['fruit']

    # If this is e-mail only, set that falg
    if args[0].nil?
      export_params[:email] = true
    end

    # Create our new export
    export = Viaduct::Toolkit.api.database_exports.start(export_params)

    # Is an export in progress?
    if export.is_a?(MoonropeClient::Responses::ValidationError) && (export.errors['base'] || []).any? { |e| e =~ /already in progress/}
      puts "An export is already in progress for this database. Please try again later.".red
      exit 1
    end

    # Any other export starting errors?
    unless export.success?
      puts "The database export could not be started for this database.".red
      exit 1
    end

    # If this is an email, we're done now. Just let the user know and exit.
    if args[0].nil?
      puts "Export of #{database['database']['fruit']} database has been started.".green
      puts "You'll receive an email shortly.".green
      exit 0
    end

    # Keep checking the export status and download the file when it's ready to
    # be downloaded.
    puts "Exporting #{database['database']['fruit']} database...".magenta
    checks = 0
    loop do
      checks += 1
      export = Viaduct::Toolkit.api.database_exports.info(:id => export.data['id'])
      if export.success?
        if export.data['status'] == 'complete' && export.data['can_download?']
          break
        end
      end

      if checks > 600
        puts "Export did not build in time. Please try again through the web interface"
        puts "and request that the result be e-mailed to you."
        exit 1
      else
        sleep 2
      end
    end

    puts "Export build successfully. Downloading...".magenta
    if system("curl #{export.data['download_url']} -o #{args[0]}")
      puts "Export downloaded successfully to #{args[0]}".green
    else
      puts "Could not download using `curl`. Ensure you have curl installed to".red
      puts "download file using the Viaduct Toolkit.".red
      exit 1
    end
  end

end
