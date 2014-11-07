Viaduct::Toolkit.cli.command "app:deploy" do |c|
  c.syntax = "app:deploy [VERSION]"
  c.description = "Deploy the given version (or latest) for an application"
  c.option "-y", "Always deploy the latest commit without asking"
  c.option "-f", "--force-build", "Build the application if even it isn't needed"
  c.option "-i", "--no-inherit-build-env", "Do not inherit the build environment for this deployment"
  c.option "-b", "--branch BRANCH", "The branch/commit you wish to deploy (defaults to application default)"
  c.action do |args, opts|
    include Commander::Methods
    ensure_logged_in!

    puts "Getting latest commit information...".magenta
    if app = find_application

      #
      # Get the latest commits for the remote repository
      #
      commits = Viaduct::Toolkit.api.repositories.commits(:application => app['subdomain'], :limit => 1, :update => true, :branch => opts.branch)
      unless commits.success? && commit = commits.data['commits'][0]
        puts
        puts "We couldn't find any commits on `#{commits.data['branch']}` branch.".red
        puts "Please check that you have pushed your code to your repository."
        puts
        puts "  Your repository is hosted at: #{commits.data['repository']['url'].underline}"
        puts
        exit 1
      end

      details do
        heading "Latest commit for #{app['subdomain']}"
        field "Repository", commits.data['repository']['url']
        field "Branch", commits.data['branch']
        field "Commit", commit['ref'][0, 10]
        field "Message", commit['message']
      end

      unless opts.y || agree("Do you wish to deploy this commit?".blue)
        puts "OK then. We won't do anything.".green
        exit 0
      end

      deployment_params = {
        :application => app['subdomain'],
        :version => commit['ref'],
        :hold => true,
        :force_build => opts.force_build,
        :inherit_build_environment => opts.no_inherit_build_env == false ? false : true
      }
      deployment_response = Viaduct::Toolkit.api.deployments.start(deployment_params)
      if deployment_response.success?

        puts
        puts "Deployment will now start. You can view the full log in your web browser:"
        puts "https://my.viaduct.io/applications/#{app['subdomain']}/deployments/#{deployment_response.data['number']}".underline

        statuses_seen = []
        require 'eventmachine'
        EM.run do
          Viaduct::Toolkit.api.push.connected do |event|
            Viaduct::Toolkit.api.push.subscribe :deployment_status, deployment_response.data['id'].to_i
          end

          Viaduct::Toolkit.api.push.receive do |exchange, process_id, data|
            if exchange == :deployment_status
              if statuses_seen.include?(data['status'])
                next
              end
              statuses_seen << data['status']
              case data['status']
              when 'pending'
                puts
                print "Waiting for capacity to deploy".ljust(40)
                $stdout.flush
              when 'building'
                puts "[  OK  ]".green
                print "Building package".ljust(40)
                $stdout.flush
              when 'starting'
                puts "[  OK  ]".green
                print "Starting application".ljust(40)
                $stdout.flush
              when 'activating'
                puts "[  OK  ]".green
                print "Activating deployment".ljust(40)
                $stdout.flush
              when 'deployed'
                puts "[  OK  ]".green
                puts "Deployment completed successfully!".green
                puts
                puts "You can view your application at:"
                if app['main_domain']
                  puts "http://#{app['main_domain']['name']}".underline
                else
                  puts "http://#{app['viaduct_domain']}".underline
                end
                puts
                exit 0
              when 'failed'
                puts "[ FAIL ]".red
                puts
                puts "Deployment did not completed successfully.".red
                puts "You can review information about this failure at the URL provided above."
                puts
                exit 0
              end
            elsif exchange == :global && data['type'] == 'subscribed'
              Viaduct::Toolkit.api.push.send(:remove_deployment_hold, {'deployment_id' => deployment_response.data['id'].to_i})
            end
          end
        end
      else
        error "We couldn't start this deployment at this time."
      end
    end
  end
end

Viaduct::Toolkit.cli.alias_command "deploy", "app:deploy"
