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
* add `config/clamav.yml` and `config/clamav.yml.sample`
* change `config/initializers/clamav.rb` to reference the new code

## Installation and use

Add this line to your application's Gemfile:

```sh
gem 'hyrax-clamav_daemon_setup'
```


...and run the generator

```sh
bin/rails generate hyrax:clamav_daemon_setup
```

Then:

* In your rails root, run `bin/rails g hyrax:clamav_daemon_setup` to get the files
* Edit the new file `config/clamav.yml` (set up to do no virus scanning by default)
* Change your gemfile to include `gem 'clamav'` for default  Hyrax scanning,
  `gem 'clamav-client'` for potential daemon use, both if you want, 
  or neither if you're not planning on doing any virus scanning.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/billdueber/hyrax-clamav_daemon_setup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hyrax::ClamavDaemonSetup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/billdueber/hyrax-clamav_daemon_setup/blob/master/CODE_OF_CONDUCT.md).
