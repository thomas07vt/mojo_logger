

module MojoLogger
  class Configurator
    # stringio = StringIO.new(s)
    # jstrinio = org.jruby.util.IOInputStream.new(stringio)
    # logger = Java::org.apache.log4j.PropertyConfigurator.configure(jstringio)
    # logger = Java::org.apache.log4j.Logger.getLogger('Mojo')
    #

    attr_reader :properties_file

    def initialize()
      @default_appender = MojoLogger::Appender.new("MojoLogger")
      @default_appender.level = "DEBUG"
      @use_default_appender = true
      @appenders = []
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
      properties += "#{generate_custom_lines}\n"
      properties += "#{generate_appender_lines}\n"
      properties
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
      lines += @default_appender.generate_properties_string if @use_default_appender
      lines += "#{@appenders.map { |a| a.generate_properties_string }.join("\n") }"

      lines
    end

  end
end
