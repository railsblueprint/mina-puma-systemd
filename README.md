# Mina Puma

[Mina](https://github.com/mina-deploy/mina) tasks for handle with
[Puma](https://github.com/puma/puma) using [systemd](https://systemd.io).

This gem provides several mina tasks:

    mina puma:reload          # Restart puma (using phased restart)
    mina puma:restart         # Restart puma (using stop, then start)
    mina puma:start           # Start puma
    mina puma:stop            # Stop puma
    mina puma:status          # Get status
    mina puma:enable          # Enables systemd service
    mina puma:disable         # Disables systemd service

## Installation

Add this line to your application's Gemfile:

    gem 'mina-puma-systemd', require: false

And then execute:

    $ bundle

Note: by just including this gem, does not mean your development server will be Puma, for that, you need explicitly add `gem 'puma'` to your Gemfile and configure it.

## Usage

Add this to your `config/deploy.rb` file:

    require 'mina/puma-systemd'

Make sure the following settings are set in your `config/deploy.rb`:

* `deploy_to`   - deployment path
* `rails_env`   - rails environement (will default to `production`)

Make sure the following directories exists on your server (they are added automatically to `shared_dirs`:

* `shared/tmp/sockets` - directory for socket files.
* `shared/tmp/pids` - directory for pid files.

You can tweak some settings:

* `puma_systemctl` - systemctl command, default is ` sudo systemctl`. Other option would be `systemctl --user` if you have setup pumas as user service. 
* `puma_service_name` - puma service name , default is `puma_#{fetch(:application_name)}_#{fetch(:puma_env)}`

## Setting up server

    mina puma:install       # copies templates for puma config and systemd service to config/deploy/templates
    mina puma:print         # prints generated config files to stdout
    mina puma:print_service # prints generated systemd service to stdout
    mina puma:print_config  # prints generated puma.rb to stdout
    mina puma:setup         # install config files on service in enables systemd service

Later commmand relies on sudo to work. If you don't want to grant sudo, print config files to console and install em manually.


Then:

```
$ mina puma:start
```

## Example
```ruby
require 'mina/puma_systemd'

task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    ...

    on :launch do
      ...
      invoke :'puma:reload'
    end
  end
end
```

## sudo configuration
By default plugin relies on sudo to run systemctl command. You should give proper permissions to the user which runs your app.
```bash
Cmnd_Alias SERVICES = /usr/bin/systemctl start *, /usr/bin/systemctl stop *, /usr/bin/systemctl reload *, /usr/bin/systemctl restart *, /usr/bin/systemctl status *, /usr/bin/systemctl enable *, /usr/bin/systemctl disable *
deploy          ALL=(ALL)       NOPASSWD: SERVICES

```

If you are paranoid, substitute `*` with exact service name. Better option would be to run as user service, but it did not work for me out of box on AWS AMI2.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
