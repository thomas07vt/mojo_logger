require 'java'
require 'time'
require 'json'
require 'stringio'
require 'forwardable'
require_relative '../jars/log4j-1.2.17.jar'

module MojoLogger
  extend SingleForwardable
  def_delegators :logger, :debug, :info, :warn, :error, :fatal

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

  def mojo_fatal(*args)
    MojoLogger.mojo_fatal(*args)
  end

  def logger
    MojoLogger.logger
  end

  def level
    MojoLogger.level
  end

  class << self

    def logger
      @@logger ||= configure_logger
    end

    def mojo_msg(*args)
      msg = {
        'time' => Time.now.utc.strftime("%m-%d-%Y %H:%M:%S.%L %z"),
        'app'  => configurator.application_name,
        'env'  => configurator.env
      }.merge!(configurator.adapter.format(*args))

      msg.to_json
    end

    def mojo_debug(*args)
      if level == :debug
        logger.debug(mojo_msg(*args))
      end
    end

    def mojo_info(*args)
      if level == :debug || level == :info
        logger.info(mojo_msg(*args))
      end
    end

    def mojo_warn(*args)
      unless level == :error || level == :fatal
        logger.warn(mojo_msg(*args))
      end
    end

    def mojo_error(*args)
      unless level == :fatal
        logger.error(mojo_msg(*args))
      end
    end

    def mojo_fatal(*args)
      logger.fatal(mojo_msg(*args))
    end

    def default_log_level
      configurator.default_log_level
    end

    def level
      @level ||= configurator.default_log_level.downcase.to_sym
    end

    def config
      if block_given?
        @@config = MojoLogger::Configurator.new
        yield(@@config)
        @@logger = configure_logger
      end

      @level = configurator.default_log_level.downcase.to_sym
      configurator
    end

    private

    def configurator
      @@config ||= MojoLogger::Configurator.new
    end

    def configure_logger
      stringio = StringIO.new(configurator.generate_properties_string)
      java_stringio = org.jruby.util.IOInputStream.new(stringio)

      Java::org.apache.log4j.PropertyConfigurator.configure(java_stringio)
      Java::org.apache.log4j.Logger.getLogger('MojoLogger')
    end

    def process_options(options=nil)
      case options
      when Hash
        options
      when String
        { 'options' => options }
      else
        nil
      end
    end

  end # End 'class' methods

end
