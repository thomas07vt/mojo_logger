require 'forwardable'

module MojoLogger
  class Configurator
    extend Forwardable

    ENV_MAPPING = {
      'development' => 'dev',
      'stage'       => 'stg',
      'production'   => 'prd'
    }

    attr_reader :properties_file, :env
    attr_accessor :application_name
    def_delegators :@default_appender, :pattern, :pattern=
    def_delegators :@default_appender, :max_file_size, :max_file_size=
    def_delegators :@default_appender, :max_backup_index, :max_backup_index=

    def initialize()
      @default_appender       = MojoLogger::Appender.new("MojoLogger")
      @default_appender.level = "DEBUG"
      @use_default_appender   = true
      @appenders              = []
      @application_name       = "Mojo"
      @adapter                = DefaultAdapter.new
      @env                    = environment
    end

    def default_log_level
      @default_appender.level
    end

    def default_log_level=(lvl)
      @default_appender.level = lvl
    end

    def log_file=(file)
      @default_appender.file = file
    end

    def properties_file=(file)
      raise "FileNotFound" unless File.exist?(file)
      @type = :file
      @properties_file = File.expand_path(file)
    end

    def custom_line(line)
      @custom_lines ||= []
      @custom_lines << line
    end

    def add_appender(appender)
      raise "InvalidAppender" unless appender.is_a?(MojoLogger::Appender)
      @appenders << appender
    end

    def generate_properties_string
      properties = "#{generate_root_logger_line}\n"
      properties << "#{generate_custom_lines}\n"
      properties << "#{generate_appender_lines}\n"
      properties
    end


    def adapter=(adapter)
      @adapter = adapter
    end

    def adapter
      @adapter
    end

    private

    def generate_root_logger_line
      "log4j.rootLogger=#{default_log_level}#{list_appenders}"
    end

    def list_appenders
      names = @appenders.map { |a| a.name }
      names.unshift(@default_appender.name) if @use_default_appender
      ", #{names.join(',')}"
    end

    def generate_custom_lines
      "#{@custom_lines.join("\n") if @custom_lines}"
    end

    def generate_appender_lines
      lines = ''
      lines << @default_appender.generate_properties_string if @use_default_appender
      lines << "#{@appenders.map { |a| a.generate_properties_string }.join("\n") }"

      lines
    end

    def environment
      env_var = ENV['RAILS_ENV'] || ENV['RACK_ENV']
      ENV_MAPPING.fetch(env_var, env_var)
    end

  end
end
