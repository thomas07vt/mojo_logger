require_relative  'spec_helper'

describe MojoLogger::Configurator do
  before do
    @config = MojoLogger::Configurator.new
  end
  it 'has a default log level of debug' do
    expect(@config.default_log_level).to eq("DEBUG")
  end

  it 'accepts a root log level' do
    @config.default_log_level = "WARN"
    expect(@config.default_log_level).to eq("WARN")
  end

  it 'accepts a log4j.properties file' do
    @config.properties_file = 'conf/log4j.properties'
    expect(@config.properties_file).to eq(File.expand_path('conf/log4j.properties'))
  end

  it 'accepts additional property lines' do
    line = "log4j.logger.org.apache.zookeeper.ClientCnxn=INFO"
    @config.custom_line(line)

    expect(@config.generate_properties_string.include?(line)).to \
      eq(true)
  end


  it 'accepts multiple appenders' do
    appender = MojoLogger::Appender.new("NEW")
    @config.add_appender(appender)
    expect(@config.instance_variable_get(:@appenders).include?(appender)).to eq(true)
  end

  it 'accepts a log file parameter' do
    @config.log_file = 'conf/test.log'
  end

  context '#generate_properties_string' do

    it 'lists the default appender' do
      res = @config.generate_properties_string
      expect(res.include?("MojoLogger")).to eq(true)
    end

    it 'lists the default_log_level' do
      res = @config.generate_properties_string
      expect(res.include?("log4j.rootLogger=#{@config.default_log_level}")).to eq(true)
    end

    it 'lists additional appenders passed to configurator' do
      appender = MojoLogger::Appender.new("NewAppender")
      @config.add_appender(appender)
      res = @config.generate_properties_string
      expect(res.include?("NewAppender")).to eq(true)
    end

    it 'contains all custom lines' do
      @config.custom_line("some line")
      @config.custom_line("another one")
      res = @config.generate_properties_string
      expect(res.include?("some line")).to eq(true)
      expect(res.include?("another one")).to eq(true)
    end

  end

  it 'accepts an application name' do
    @config.application_name = "MojoLogger"
    expect(@config.application_name).to eq("MojoLogger")
  end

end
