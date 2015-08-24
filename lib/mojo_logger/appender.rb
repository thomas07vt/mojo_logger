module MojoLogger
  class Appender

    ACCEPTABLE_LOG_LEVELS = [
      "DEBUG",
      "INFO",
      "WARN",
      "ERROR",
      "FATAL"
    ]

    attr_reader :name, :level, :file
    attr_accessor :pattern, :max_file_size, :max_backup_index

    def initialize(name, opts={})
      @name = name
      set_defaults(opts)
    end

    def level=(lvl)
      l = lvl.to_s.upcase
      raise "InvalidLogLevel" unless valid_log_level?(l)
      @level = l
    end

    def file=(file)
      raise "FileNotFound" unless File.exist?(file)
      @type = :file
      @file = File.expand_path(file)
    end

    def generate_properties_string
      properties = generate_generic_properties
      properties += generate_file_properties if @file
      properties
    end

    private

    def valid_log_level?(lvl)
      ACCEPTABLE_LOG_LEVELS.include?(lvl)
    end

    def set_defaults(opts={})
      @type = :console
      @max_file_size    = opts[:max_file_size]    || '10MB'
      @max_backup_index = opts[:max_backup_index] || '10'
      @pattern          = opts[:pattern]          || '%m %n'

      self.level=(opts[:level]) if opts[:level]
      self.file=(opts[:file]) if opts[:file]
    end

    def property_header
      "log4j.appender.#{@name}"
    end

    def generate_generic_properties
      properties = "#{property_header}=#{log4j_type}\n"
      properties += "#{property_header}.layout=org.apache.log4j.PatternLayout\n"
      properties += "#{property_header}.layout.ConversionPattern=#{@pattern}\n"
      properties += "#{property_header}.Threshold=#{@level}\n" if @level
      properties
    end

    def generate_file_properties
      properties = "#{property_header}.file=#{@file}\n"
      properties += "#{property_header}.MaxFileSize=#{@max_file_size}\n"
      properties += "#{property_header}.MaxBackupIndex=#{@max_backup_index}\n"
      properties
    end

    def log4j_type
      if @type == :file
        "org.apache.log4j.RollingFileAppender"
      else
        "org.apache.log4j.ConsoleAppender"
      end
    end

  end
end
