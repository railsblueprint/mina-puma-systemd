require 'mina/bundler'
require 'mina/rails'

namespace :puma do
  set :shared_dirs, fetch(:shared_dirs, []).push("tmp/sockets", "tmp/pids")

  set :puma_user,      -> { fetch(:user) }
  set :puma_group,     -> { fetch(:user) }
  set :puma_env,       -> { fetch(:rails_env, 'production') }
  set :puma_root_path, -> { fetch(:current_path) }

  set :puma_bundle_exec, -> { "/home/#{fetch(:puma_user)}/.rbenv/bin/rbenv exec bundle exec" }
  set :systemd_root, -> { "/etc/systemd/system" }

  set :puma_systemctl, -> { fetch(:systemctl, "sudo systemctl")}
  set :puma_service_name, -> { "puma_#{fetch(:application_name)}_#{fetch(:puma_env)}" }
  set :puma_service_config, -> { "#{fetch(:systemd_root)}/#{fetch(:puma_service_name)}.service" }
  set :puma_config, -> { "#{fetch(:shared_path)}/puma.rb" }

  set :puma_workers, 0
  set :puma_threads, "1,5"

  set :puma_restart_command, "bundle exec puma"
  set :puma_preload_app, false
  set :puma_init_active_record, true

  desc 'Enable puma'
  task enable: :remote_environment do
    comment "Enabling Puma..."
    command "#{fetch(:puma_systemctl)} enable #{fetch(:puma_service_name)}"
  end

  desc 'Disable puma'
  task start: :remote_environment do
    comment "Enabling Puma..."
    command "#{fetch(:puma_systemctl)} disable #{fetch(:puma_service_name)}"
  end

  desc 'Start puma'
  task start: :remote_environment do
    comment "Starting Puma..."
    command "#{fetch(:puma_systemctl)} start #{fetch(:puma_service_name)}"
  end

  desc 'Stop puma'
  task stop: :remote_environment do
    comment "Stopping Puma..."
    command "#{fetch(:puma_systemctl)} stop #{fetch(:puma_service_name)}"
  end

  desc 'Restart puma'
  task restart: :remote_environment do
    comment "Restart Puma...."
    command "#{fetch(:puma_systemctl)} restart #{fetch(:puma_service_name)}"
  end

  desc 'Reload puma (phased restart)'
  task reload: :remote_environment do
    command %[
      if #{fetch(:puma_systemctl)} is-active --quiet #{fetch(:puma_service_name)} ; then
        echo "Reload Puma -- phased..."
        #{fetch(:puma_systemctl)} reload #{fetch(:puma_service_name)}
      else
        echo "Starting Puma..."
        #{fetch(:puma_systemctl)} start #{fetch(:puma_service_name)}
      fi
    ]
  end

  desc 'Get status of puma'
  task status: :remote_environment do
    comment "Puma status..."
    command "#{fetch(:puma_systemctl)} status -l #{fetch(:puma_service_name)}"
  end


  desc 'Install Puma config template to repo'
  task :install do
    run :local do
      if File.exist? path_for_service_template
        error! %(file exists; please rm to continue: #{path_for_service_template})
      else
        command %(mkdir -p config/deploy/templates)
        command %(cp #{path_for_service_template(installed: false)} #{path_for_service_template})
      end
      if File.exist? path_for_config_template
        error! %(file exists; please rm to continue: #{path_for_config_template})
      else
        command %(mkdir -p config/deploy/templates)
        command %(cp #{path_for_config_template(installed: false)} #{path_for_config_template})
      end
    end
  end

  desc 'Print nginx config in local terminal'
  task :print do
    puts "----  puma.service ----------"
    puts processed_puma_service_template
    puts "----  puma.rb ---------------"
    puts processed_puma_config_template
  end

  desc 'Print puma service config in local terminal'
  task :print_service do
    puts processed_puma_service_template
  end

  desc 'Print puma config in local terminal'
  task :print_config do
    puts processed_puma_config_template
  end

  desc 'Setup puma service on server'
  task :setup do
    puma_service_config = fetch(:puma_service_config)
    puma_config = fetch(:puma_config)

    comment %(Installing puma service config file to #{puma_service_config})
    command %(echo -ne '#{escaped_puma_service_template}' | sudo tee #{puma_service_config} > /dev/null)

    comment %(Installing puma.rb config file to #{puma_config})
    command %(echo -ne '#{escaped_puma_config_template}' > #{puma_config})

    invoke :'puma:enable'
  end

  def path_for_service_template installed: true
    installed ?
      File.expand_path('./config/deploy/templates/puma.service.template') :
      File.expand_path('../../templates/puma.service.template', __FILE__)
  end

  def path_for_config_template installed: true
    installed ?
      File.expand_path('./config/deploy/templates/puma.rb.template') :
      File.expand_path('../../templates/puma.rb.template', __FILE__)
  end

  def puma_service_template
    installed_path = path_for_service_template
    template_path = path_for_service_template installed: false

    File.exist?(installed_path) ? installed_path : template_path
  end

  def processed_puma_service_template
    erb = File.read(puma_service_template)
    ERB.new(erb, trim_mode: '-').result(binding)
  end

  def escaped_puma_service_template
    processed_puma_service_template.gsub("\n","\\n").gsub("'","\\'")
  end

  def puma_config_template
    installed_path = path_for_config_template
    template_path = path_for_config_template installed: false

    File.exist?(installed_path) ? installed_path : template_path
  end

  def processed_puma_config_template
    erb = File.read(puma_config_template)
    ERB.new(erb, trim_mode: '-').result(binding)
  end

  def escaped_puma_config_template
    processed_puma_config_template.gsub("\n","\\n").gsub("'","\\'")
  end

end
