require 'java'
require 'time'
require 'json'
require_relative '../../jars/log4j-1.2.17.jar'

module MojoLogger

  def mojo_debug(*args)
    MojoLogger.mojo_debug(*args)
  end

  def mojo_info(*args)
    MojoLogger.mojo_info(*args)
  end

  def mojo_warn(*args)
    MojoLogger.mojo_warn(*args)
  end

  def mojo_error(*args)
    MojoLogger.mojo_error(*args)
  end

  def logger
    MojoLogger.logger
  end

  class << self

    def logger
      @@logger ||= configure_logger
    end

    def mojo_msg(api_request, category, message, options=nil)
      msg = {
        'time' => Time.now.utc.strftime("%m-%d-%Y %H:%M:%S.%L %z"),
        'app' => "Mojo",
        'session_id' => api_request[:session_id],
        'reference_id' => api_request[:reference_id],
        'api' => api_request[:api],
        'category' => category,
        'message' => message
      }

      msg.merge!(options) if options
      msg.to_json
    end

    def mojo_debug(*args)
      logger.debug(mojo_msg(*args))
    end

    def mojo_info(*args)
      logger.info(mojo_msg(*args))
    end

    def mojo_warn(*args)
      logger.warn(mojo_msg(*args))
    end

    def mojo_error(*args)
      logger.error(mojo_msg(*args))
    end

  private

    def configure_logger
      # Need a configurator
      Java::org.apache.log4j.PropertyConfigurator.configure("#{File.dirname(__FILE__)}/../../conf/log4j.properties")
      Java::org.apache.log4j.Logger.getLogger('Mojo')
    end

  end # End 'class' methods

end
