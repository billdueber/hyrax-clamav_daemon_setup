module Hyrax
  module Generators
    class ClamavDaemonSetup < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc '
  Configure your hyrax instance to use a ClamAV Daemon, the normal
  hyrax clamav, or no virus scanning at all, depending on how
  you configure config/clamav.yml and what gems are in your
  gemfile
  '

      def run_setup
        directory 'lib/clamav'
        copy_file "config/initializers/clamav.rb"
        copy_file "config/clamav.yml"
      end
    end
  end
end
