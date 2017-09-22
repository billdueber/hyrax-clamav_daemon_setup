# Hyrax::ClamavDaemonSetup

Sets up a Hyrax application to (optionally) use the `clamd` ClamAV daemon
if it's running.

Main features:

* Allows use of the clamav daemon
* Can configure virus scanning by Rails env
* Allows use of the `clamav` gem (Hyrax default as of this writing)
* Doesn't complain if `clamav` or `clamav-client` aren't installed (so
  you don't have to worry about setting up clamav on your dev machines)
* Has an explicit `none` option to turn off virus scanning altogether
* Easy configuration via `config/clamav.yml`

## What get installed/changed

* add `lib/clamav/clamav_setup` and `lib/clamav/daemon/scanner`
* add `config/clamav.yml` with a default configuration of "no virus scanning"
* change `config/initializers/clamav.rb` to reference the new code

## Installation

Add this line to your application's Gemfile:

```sh
gem 'hyrax-clamav_daemon_setup'
```


...get it installed

```sh
bundle install
```

Then:

* In your rails root, run the generator
  * `bin/rails g hyrax:clamav_daemon_setup`
* Change your gemfile to include:
  * `gem 'clamav'` for default  Hyrax scanning,
  * `gem 'clamav-client'` for potential daemon use, 
  * both if you want, 
  * ...or neither if you're not planning on doing any virus scanning.

## Configuring

First off, you need to make sure your Gemfile has `clamav` and/or `clamav-client`
if you want to do any virus scanning.

Everything is then configured in `config/clamav.yml`. A sample looks like this:

```yaml

# Define clamav services for each Rails environment
#
# service can be
#  default (use the default Hyrax clamav process version)
#  daemon (use a daemon, needs port and host)
#  none (don't do any scanning regardless of what's loaded)

## DEFAULT
# If you specify the "default" scanner
#  * Must have `gem "clamav"` in your Gemfile
#  * Will use the default Hyrax scanner
#
#  If the `clamav` gem can't be found
#  it'll log a warning and just not scan anything

### DAEMON
# If you specify 'daemon'
#   * You need `gem "clamav-client"` in your Gemfile
#   * You must set the port and host for the daemon
# You'll throw errors in these conditions:
#  * The port and host aren't set
#  * The 'clamav-client' gem isn't installed
#  * The daemon specified can't be contacted

### NONE
# Will log a warning and not do any virus scanning,
# regardless of the other settings

# Example
# testing:
#   service: none
# development:
#   service: default
# production:
#   service: none
#   port: 3310
#   host: 127.0.0.1


testing:
  service: none
development:
  service: daemon
  port: 3310
  host: 127.0.0.1
production:
  service: default


```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/billdueber/hyrax-clamav_daemon_setup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hyrax::ClamavDaemonSetup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/billdueber/hyrax-clamav_daemon_setup/blob/master/CODE_OF_CONDUCT.md).
