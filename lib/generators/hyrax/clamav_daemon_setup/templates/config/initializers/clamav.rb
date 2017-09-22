require 'yaml'
require 'erb'
require "clamav/clamav_setup"


# Configure virus scanning in config/clamav.yml, and only
# mess with this if you have to

Rails.logger.tagged("ClamAVSetup") do
  if defined? ClamAV and !(ENV['CI'] == 'true')
    begin
      Rails.logger.info "Beginning setup of clamav"
      conf = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'clamav.yml'))).result)[Rails.env].with_indifferent_access
      Hydra::Works.default_system_virus_scanner = ClamAVSetup.virus_scanner(conf, Rails.logger)
    rescue => e
      raise "Can't set up clamav using config/clamav.yml: #{e}"
    end
  else
    Rails.logger.warn "No ClamAV gem found and/or CI=#{ENV['CI']}; not going to try to do any virus scanning"
  end
end
