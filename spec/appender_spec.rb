require_relative  'spec_helper'

describe MojoLogger::Appender do
  before do
    @apndr = MojoLogger::Appender.new("Rspec")
  end

  context '.initialize' do
    it 'requires a name' do
      a = MojoLogger::Appender.new("console")
      expect(a.name).to eq("console")
    end
  end

  context '#level=' do
    it 'sets @level when a symbol is given' do
      @apndr.level = :debug
      expect(@apndr.level).to eq("DEBUG")
    end

    it 'sets @level when a string is given' do
      @apndr.level = "warn"
      expect(@apndr.level).to eq("WARN")
    end

    it 'raises when an invalid level is given' do
      expect { @apndr.level = 'not_valid' }.to \
        raise_error
    end

  end

  context '#file' do
    it 'accepts a path the a log4j.properties file' do
      @apndr.file = 'conf/log4j.properties'
      expect(@apndr.file).to eq('conf/log4j.properties')
    end
  end

  context '#generate_properties_string' do
    it 'generates a console string correctly.' do
      res = @apndr.generate_properties_string
      expect(res.include?("org.apache.log4j.ConsoleAppender")).to eq(true)
    end
    it 'generates file properties when a file is given' do
      @apndr.file = 'file/file.log'
      res = @apndr.generate_properties_string
      expect(res.include?("org.apache.log4j.RollingFileAppender")).to eq(true)
    end
  end

end

