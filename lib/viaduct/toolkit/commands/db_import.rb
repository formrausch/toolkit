Viaduct::Toolkit.cli.command "db:import" do |c|

  c.syntax = "db:import [PATH]"
  c.description = "Import a dump file to a database"
  c.option "--database FRUIT", String, "The name of the database to import into (uses the main DB by default)"

  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    if args[0].nil? || !File.file?(args[0])
      puts "You must provide a path to the dump file to import".red
      exit 1
    end

    # Get the application
    app = find_application

    # Get the database
    database = find_database(app, opts.database)

    # Set some parameters to create our new  export with
    import_params = {}
    import_params[:application] = app['subdomain']
    import_params[:database]    = database['database']['fruit']
    import_params[:file]        = Base64.encode64(File.read(args[0]))

    # Start the import
    puts "Uploading #{args[0]} to Viaduct...".magenta
    import = Viaduct::Toolkit.api.database_imports.import(import_params)
    unless import.success?
      puts "Couldn't start this import. Ensure that the type of database supports importing.".red
      exit 1
    end

    puts "Importing #{args[0]} into #{database['database']['fruit']} database...".magenta

    # Keep checking in on the status
    count = 0
    loop do
      count += 1
      import = Viaduct::Toolkit.api.database_imports.info(:id => import.data['id'])
      if import.success? && ['complete', 'failed'].include?(import.data['status'])
        case import.data['status']
        when 'complete'
          puts "Database has been imported successfully.".green
        else
          puts "The database import failed. You can use the console to try and".red
          puts "import your file directly into your database. See documentation".red
          puts "for further details".red
        end
        exit 0
      end

      if count > 600
        break
      else
        sleep 2
      end
    end

    # Oh no, it timed out.
    puts "The database import did not complete in a timely manner. Please try".red
    puts "again later or contact support.".red
    exit 1
  end

end
