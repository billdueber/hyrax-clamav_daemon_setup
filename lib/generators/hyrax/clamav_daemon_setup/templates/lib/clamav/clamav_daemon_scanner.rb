# An AV class that streams the file to an already-running
# clamav daemon
require 'clamav/client'
class ClamAVDaemonScanner < Hydra::Works::VirusScanner
#  include SemanticLogger::Loggable

  CHUNKSIZE = 4096


  class CannotConnectClient
  end

  attr_accessor :client
  attr_reader :logger

  def initialize(port:, host:, logger:)
    @logger = logger
    @client = begin
      connection = ClamAV::Connection.new(socket:  ::TCPSocket.new(host, port),
                                          wrapper: ::ClamAV::Wrappers::NewLineWrapper.new)
      ClamAV::Client.new(connection)
    rescue Errno::ECONNREFUSED => e
      @logger.warn("Connection refused for ClamAV: #{e}")
      CannotConnectClient.new
    end
  end

  # Check to see if we can connect to the configured
  # ClamAV daemon
  def alive?
    case client
    when CannotConnectClient
      false
    else
      client.execute(ClamAV::Commands::PingCommand.new)
    end
  end

  # Check to see if the file passed on `#new` is infected
  # Reports `true` if a virus is found, `false` for all other
  # states (no virus or some sort of error)
  def infected?(file)
    unless alive?
      logger.warn "Cannot connect to virus scanner. Skipping file #{file}"
      return false
    end
    resp = scan_response(file)
    case resp
    when ClamAV::SuccessResponse
      logger.info(message: "Clean virus check for '#{file}'",
                  payload: {file: file, scanned: true, clean: true})
      false
    when ClamAV::VirusResponse
      logger.warn(message: "Virus found!",
                  payload: {file: file, virus: resp.virus_name, scanned: true, clean: false})
      true
    when ClamAV::ErrorResponse
      logger.warn(message: "ClamAV error: #{resp.error_str} for file #{file}. File not scanned!",
                  payload: {file: file, scanned: false})
      false # err on the side of trust? Need to think about this
    else
      logger.warn(message: "ClamAV response unknown type '#{resp.class}': #{resp}. File not scanned!",
                  payload: {file: file, scanned: false})
      false
    end
  end

  def scan_response(file)
    begin
      file_io = File.open(file, 'rb')
    rescue => e
      msg = "Can't open file #{file} for scanning: #{e}"
      logger.error(msg, e)
      raise RuntimeError.new(msg)
    end

    scan(file_io)
  end


  # Do the scan by streaming to the daemon
  # @param [#read] io The IO stream (probably an open file) to read from
  # @return A ClamAV::*Response object
  def scan(io)
    cmd = InstreamScanner.new(io, CHUNKSIZE)
    client.execute(cmd)
  end


  # Stream a file to the AV scanner in chucks to avoid
  # reading it all into memory. Internal to how
  # ClamAV::Client works
  class InstreamScanner < ClamAV::Commands::InstreamCommand
    def call(conn)
      conn.write_request("INSTREAM")
      while (packet = @io.read(@max_chunk_size))
        scan_packet(conn, packet)
      end
      send_end_of_file(conn)
      av_return_status(conn)
    rescue => e
      ClamAV::ErrorResponse.new("Error sending data to ClamAV Daemon: #{e}")
    end

    def av_return_status(conn)
      get_status_from_response(conn.read_response)
    end

    def send_end_of_file(conn)
      conn.raw_write("\x00\x00\x00\x00")
    end

    def scan_packet(conn, packet)
      packet_size = [packet.size].pack("N")
      conn.raw_write("#{packet_size}#{packet}")
    end
  end

end


# To use a virus checker other than ClamAV:
#   class MyScanner < Hydra::Works::VirusScanner
#     def infected?
#       my_result = Scanner.check_for_viruses(file)
#       [return true or false]
#     end
#   end
