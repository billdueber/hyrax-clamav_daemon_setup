# A null scanner, for when you want to just turn it off

module ClamAVSetup

  class NullVirusScanner
    def infected?(file)
      Rails.logger.warn "Virus scanning turned off: file '#{file}' not checked."
      false
    end
  end

  def self.virus_scanner(conf, logger)
    ScannerFactory.new.scanner(conf, logger)
  end

  class ScannerFactory

    def scanner(conf, logger)
      case conf[:service]
      when 'default'
        default_scanner(conf, logger)
      when 'daemon'
        daemon_scanner(conf, logger)
      when 'none'
        logger.warn "Virus scanning purposefully turned off (set to 'none') for Rails env '#{Rails.env}'"
        NullVirusScanner.new
      when nil
        logger.warn "ClamAV service type not defined in config/clamav.yml; using default"
        default_scanner(conf, logger)
      else
        raise ArgumentError.new("ClamAV service unknown type #{conf[:service]}")
      end
    end


    def default_scanner(conf, logger)
      if defined? ClamAV and ClamAV.respond_to? :loaddb
        logger.warn "Using default ClamAV process (not daemon)"
        ClamAV.instance.loaddb
      else
        logger.warn "Unable to find gem 'clamav'. No virus check in use."
      end
    end


    def daemon_scanner(conf, logger)
      require 'clamav/clamav_daemon_scanner'

      unless valid_config?(conf, logger)
        raise ArgumentError.new("ClamAV Daemon needs config/clamav.yml to define host and port for Rails env '#{Rails.env}'")
      end

      logger.info "Setting up clamav daemon at #{conf[:host]}:#{conf[:port]}"
      scanner = ClamAVDaemonScanner.new(host: conf[:host], port: conf[:port], logger: logger)
      if scanner.alive?
        logger.info "Virus scanner daemon successfully contacted on #{conf[:host]}:#{conf[:port]}"
        # Hydra::Works.default_system_virus_scanner = scanner
        scanner
      else
        raise "Cannot contact scanner on #{conf[:host]}:#{conf[:port]}"
      end
    rescue LoadError => e
      Rails.logger.error "Can't set up clamav daemon: #{e}"
      raise e
    end

    def valid_config?(conf, logger)
      ['host', 'port'].map {|x| conf.has_key? x}.all? and conf['port'].to_s =~ /\A\d+\Z/
    end

  end
end
