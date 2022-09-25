require 'mina/bundler'
require 'mina/rails'

namespace :puma do
  set :shared_dirs, fetch(:shared_dirs, []).push("tmp/sockets", "tmp/pids")

  set :puma_role,      -> { fetch(:user) }
  set :puma_env,       -> { fetch(:rails_env, 'production') }
  set :puma_root_path, -> { fetch(:current_path) }

  set :puma_systemctl, -> { fetch(:systemctl, "sudo systemctl")}
  set :puma_service_name, -> { "puma_#{fetch(:application_name)}_#{fetch(:puma_env)}" }

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

end
